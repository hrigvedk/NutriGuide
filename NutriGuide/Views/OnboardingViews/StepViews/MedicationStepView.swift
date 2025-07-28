//
//  MedicationStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/7/25.
//
import SwiftUI

struct MedicationsStepView: View {
    @Binding var userData: UserProfileData
    @State private var showingAddMedication = false
    @State private var medicationToEdit: Medication?
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Medications")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Add any medications you're currently taking. This information is crucial in case of emergency and will help provide accurate dietary recommendations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if userData.medications.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("No medications added yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingAddMedication = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Medication")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                List {
                    ForEach(userData.medications) { medication in
                        MedicationRow(medication: medication)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                medicationToEdit = medication
                                isEditing = true
                                showingAddMedication = true
                            }
                    }
                    .onDelete(perform: deleteMedication)
                }
                .listStyle(PlainListStyle())
                .frame(height: min(CGFloat(userData.medications.count * 80), 300))
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Button(action: {
                    medicationToEdit = nil
                    isEditing = false
                    showingAddMedication = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Another Medication")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            
            InfoBox(
                title: "Why is this important?",
                message: "Many medications have dietary restrictions or can interact with certain foods. Having this information helps us provide safer dietary recommendations and can be crucial for first responders in an emergency."
            )
        }
        .sheet(isPresented: $showingAddMedication) {
            MedicationFormView(
                userData: $userData,
                medication: medicationToEdit,
                isEditing: isEditing,
                isPresented: $showingAddMedication
            )
        }
    }
    
    private func deleteMedication(at offsets: IndexSet) {
        userData.medications.remove(atOffsets: offsets)
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(medication.name)
                .font(.headline)
            
            HStack {
                if !medication.dosage.isEmpty {
                    Text("Dosage: \(medication.dosage)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !medication.frequency.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Frequency: \(medication.frequency)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if !medication.notes.isEmpty {
                Text("Notes: \(medication.notes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct MedicationFormView: View {
    @Binding var userData: UserProfileData
    var medication: Medication?
    var isEditing: Bool
    @Binding var isPresented: Bool
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: String = ""
    @State private var notes: String = ""
    
    private let frequencyOptions = [
        "As needed", "Once daily", "Twice daily", "Three times daily",
        "Four times daily", "Weekly", "Monthly", "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                        .autocorrectionDisabled()
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                        .autocorrectionDisabled()
                    
                    Picker("Frequency", selection: $frequency) {
                        Text("Select Frequency").tag("")
                        ForEach(frequencyOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    if frequency == "Other" {
                        TextField("Specify Frequency", text: $frequency)
                            .autocorrectionDisabled()
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let medication = medication {
                    name = medication.name
                    dosage = medication.dosage
                    frequency = medication.frequency
                    notes = medication.notes
                }
            }
        }
    }
    
    private func saveMedication() {
        if isEditing, let index = userData.medications.firstIndex(where: { $0.id == medication?.id }) {
            userData.medications[index].name = name
            userData.medications[index].dosage = dosage
            userData.medications[index].frequency = frequency
            userData.medications[index].notes = notes
        } else {
            let newMedication = Medication(
                name: name,
                dosage: dosage,
                frequency: frequency,
                notes: notes
            )
            userData.medications.append(newMedication)
        }
    }
}
