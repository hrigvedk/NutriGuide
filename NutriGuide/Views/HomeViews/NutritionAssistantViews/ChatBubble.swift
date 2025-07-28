//
//  ChatBubble.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/23/25.
//
import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.topRight, .bottomLeft, .bottomRight])
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            )
                        
                        Text(message.text)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                            .cornerRadius(4, corners: [.topLeft, .bottomLeft, .bottomRight])
                    }
                }
                
                Spacer()
            }
        }
    }
}
