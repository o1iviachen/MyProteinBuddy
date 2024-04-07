//
//  SelectorViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-21.
//

import UIKit
import Firebase

class SelectorViewController: UIViewController {
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var proteinSlider: UISlider!
    var proteinAmount = 0
    
    let db = Firestore.firestore()
    




    @IBAction func proteinChanged(_ sender: UISlider) {
        proteinLabel.text = "\(String(Int(sender.value)))g"
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        proteinAmount = Int(proteinSlider.value)
        showResult(proteinAmount: proteinAmount)
        
    }
    
    func showResult(proteinAmount: Int) {
        let alert = UIAlertController(title: "Completed!", message: "Your protein goal is now \(proteinAmount)g. You can change this at any time on the profile page.", preferredStyle: .alert)
        
        // Add an UIAlertAction with a handler to perform the segue
        let gotItAction = UIAlertAction(title: "Got It!", style: .default) { (action) in
            // Perform the segue when the "Got It!" button is tapped
            if self.canPerformSegue(withIdentifier: K.proMainSegue) {
                self.performSegue(withIdentifier: K.proMainSegue, sender: self)
                
                self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([ "protein_goal": proteinAmount], merge: true)
                UserDefaults.standard.set(proteinAmount, forKey: "proteinGoal")

            } else {
                UserDefaults.standard.set(proteinAmount, forKey: "proteinGoal")
                self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([ "protein_goal": proteinAmount], merge: true)
                self.navigationController?.popViewController(animated: true)

                
            }
        }
        alert.addAction(gotItAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension UIViewController {
    func canPerformSegue(withIdentifier id: String) -> Bool {
        guard let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
        return segues.first { $0.value(forKey: "identifier") as? String == id } != nil
    }
}
