//
//  SocialLogin.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//

import SwiftUI

struct SocialLoginButton: View {
    enum SocialType {
        case apple
        case google
        
        var iconName: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle.fill"
            }
        }
    }
    
    let type: SocialType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: type.iconName)
                .font(.title2)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(30)
        }
    }
}
