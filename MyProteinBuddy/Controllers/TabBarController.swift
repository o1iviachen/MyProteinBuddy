//
//  TabBarController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-06.
//

import Foundation
import UIKit
import Firebase

class TabBarController: UITabBarController {
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let mealMaps = [
            "breakfast": [],
            "lunch": [],
            "dinner": []
        ]
        db.collection("users").document((Auth.auth().currentUser?.email)!).setData([ dateString: mealMaps], merge: true)
    }
    
    
    
}
