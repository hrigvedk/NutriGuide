//
//  ChatMessage.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/23/25.
//
import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromUser: Bool
    let timestamp: Date = Date()
}
