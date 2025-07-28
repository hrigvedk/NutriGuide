//
//  EmergencyContactStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/7/25.
//
import SwiftUI


struct EmergencyContactStepView: View {
    @Binding var userData: UserProfileData
    
    func isValidPhone(_ phone: String) -> Bool {
        return phone.count <= 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Emergency Contact")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Provide information for someone who should be contacted in case of a medical emergency.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.headline)
                    
                    TextField("Contact's full name", text: $userData.emergencyContact.name)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Relationship")
                        .font(.headline)
                    
                    TextField("e.g. Spouse, Parent, Friend", text: $userData.emergencyContact.relationship)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.headline)
                    
                    TextField("Contact's phone number", text: $userData.emergencyContact.phone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    if !userData.emergencyContact.phone.isEmpty && !isValidPhone(userData.emergencyContact.phone) {
                            Text("Contact Number should have only 10 digits")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                }
                
                Toggle(isOn: $userData.emergencyContact.isAuthorized) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Medical Information Access")
                            .font(.headline)
                        
                        Text("Allow this contact to access my medical information in an emergency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            InfoBox(
                title: "Privacy Note",
                message: "Emergency contact information will only be used in case of a medical emergency. Your contact's information is stored securely and will not be shared with third parties."
            )
        }
    }
}
