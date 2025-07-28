//
//  WatchConnectivityHandler.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/6/25.
//
import Foundation
import WatchConnectivity

class WatchConnectivityHandler: NSObject, ObservableObject, WCSessionDelegate {
    @Published var emergencyData: [String: Any] = [:]
    @Published var lastUpdated: Date? = nil
    
    static let shared = WatchConnectivityHandler()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("WatchConnectivityHandler: WCSession activated successfully")
        } else if let error = error {
            print("WatchConnectivityHandler: WCSession activation failed: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        DispatchQueue.main.async {
            self.emergencyData = userInfo
            self.lastUpdated = Date()
            
            NotificationCenter.default.post(name: NSNotification.Name("EmergencyDataUpdated"), object: nil)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["command"] as? String == "update_emergency_info" {
            DispatchQueue.main.async {
                replyHandler(["success": true])
            }
        }
    }
}
