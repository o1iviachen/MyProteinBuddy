//
//  AppDelegate.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-06-30.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreData


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        
        let userDefaults = UserDefaults.standard
        if let userEmail = Auth.auth().currentUser?.email {
            let docRef = db.collection("users").document(userEmail)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let proteinGoal = document.data()?["protein_goal"]
                    
                    userDefaults.set(proteinGoal ?? 0, forKey: "proteinGoal")
                    
                } else {
                    userDefaults.set(0, forKey: "proteinGoal")
                    
                }
            }
        }
        return true
        
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    

    
    
    
}



