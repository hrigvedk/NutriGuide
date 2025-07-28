//
//  EmergencyCardView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/6/25.
//
import SwiftUI

struct EmergencyCardView: View {
    @ObservedObject private var connectivityHandler = WatchConnectivityHandler.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("Emergency Info")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(.top, 5)
                
                Divider()
                
                if let name = connectivityHandler.emergencyData["name"] as? String {
                    infoSection(title: "Name", value: name)
                } else {
                    infoSection(title: "Name", value: "Not available")
                }
                
                if let emergencyContactName = connectivityHandler.emergencyData["emergencyContactName"], let emergencyContactRelationship = connectivityHandler.emergencyData["emergencyContactRelationship"], let emergencyContactPhone = connectivityHandler.emergencyData["emergencyContactPhone"] {
                    let contactVal = "\(emergencyContactName): \(emergencyContactPhone)"
                    infoSection(title: "Emergency Contact (\(emergencyContactRelationship))", value: contactVal)
                } else {
                    infoSection(title: "Emergency Contact", value: "Not available") 
                }
                
                if let conditions = connectivityHandler.emergencyData["healthConditions"] as? [String], !conditions.isEmpty {
                    infoSection(title: "Health Conditions", value: conditions.joined(separator: ", "))
                } else {
                    infoSection(title: "Health Conditions", value: "None reported")
                }
                
                if let allergies = connectivityHandler.emergencyData["allergens"] as? [String], !allergies.isEmpty {
                    infoSection(title: "Allergies", value: allergies.joined(separator: ", "))
                } else {
                    infoSection(title: "Allergies", value: "None reported")
                }
                
                if let medications = connectivityHandler.emergencyData["medications"] as? [[String: Any]], !medications.isEmpty {
                    let medicationDetails = medications.compactMap { medication -> String? in
                        guard let name = medication["name"] as? String else { return nil }
                        
                        var details = name
                        if let dosage = medication["dosage"] as? String, !dosage.isEmpty {
                            details += ": \(dosage)"
                        }
                        return details
                    }
                    
                    if !medicationDetails.isEmpty {
                        infoSection(title: "Medications", value: medicationDetails.joined(separator: ", "))
                    } else {
                        infoSection(title: "Medications", value: "None added")
                    }
                } else {
                    infoSection(title: "Medications", value: "None added")
                }
                
                Divider()
                
                if let lastUpdated = connectivityHandler.lastUpdated {
                    Text("Last updated: \(timeAgoString(from: lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.horizontal)
        }
        .navigationTitle("NutriGuide")
    }
    
    private func infoSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        print("Test: \(connectivityHandler.emergencyData)")
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

