//
//  InitialCalculatorViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-19.
//

import UIKit
import Firebase

class InitialCalculatorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        
        
        
    }
    
    var leanness: Float = 0.0
    var height: Float = 0.0
    var weight: Float = 0.0
    var bmiValue = 0.0
    let db = Firestore.firestore()
    @IBOutlet weak var heightSlider: UISlider!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var weightSlider: UISlider!
    @IBOutlet weak var leannessSlider: UISlider!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var leannessLabel: UILabel!
    
    
    
    @IBAction func heightChanged(_ sender: UISlider) {
        heightLabel.text = "\(String(format: "%.2f", sender.value))m"
    }
    
    @IBAction func weightChanged(_ sender: UISlider) {
        weightLabel.text = "\(Int(sender.value))kg"
    }
    
    
    @IBAction func leannessChanged(_ sender: UISlider) {
        leanness = sender.value
        switch leanness {
        case 0.0..<0.25:
            leannessLabel.text = "Not lean"
        case 0.25..<0.5:
            leannessLabel.text = "Slightly lean"
        case 0.5..<0.75:
            leannessLabel.text = "Lean"
        case 0.75...1.0:
            leannessLabel.text = "Slightly lean"
        default:
            leannessLabel.text = "Error"
        }
    }
    
    
    @IBAction func calculateGoal(_ sender: UIButton) {
        leanness = leannessSlider.value
        height = heightSlider.value
        weight = weightSlider.value
        bmiValue = Double(weight) / Double(height * height)
        var proteinIntake: String = ""
        if bmiValue < 24.9 {
            switch leanness {
            case 0.0..<0.25:
                proteinIntake = String(Int(weight*2.2*0.8))
            case 0.25..<0.75:
                proteinIntake = String(Int(weight*2.2*1.0))
            case 0.75...1.0:
                proteinIntake = String(Int(weight*2.2*1.2))
            default:
                proteinIntake = "Error"
            }
        } else if bmiValue >= 24.9 {
            switch leanness {
            case 0.0..<0.33:
                proteinIntake = String(Int(height*100))
            case 0.33..<0.66:
                proteinIntake = String(Int(weight*2.2*1.0))
            case 0.66...1.0:
                proteinIntake = String(Int(weight*2.2*1.2))
            default:
                proteinIntake = "Error"
            }
        }
        showResult(proteinAmount: proteinIntake)
    }
    
    func showResult(proteinAmount: String) {
        if proteinAmount != "Error" {
            let alert = UIAlertController(title: "Completed!", message: "Your protein goal is now \(proteinAmount)g. You can change this at any time on the profile page.", preferredStyle: .alert)
            
            // Add an UIAlertAction with a handler to perform the segue
            let gotItAction = UIAlertAction(title: "Got It!", style: .default) { (action) in
                // Perform the segue when the "Got It!" button is tapped
                
                // Update one field, creating the document if it does not exist.
                self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData(["protein_goal": Int(proteinAmount)!], merge: true)
                UserDefaults.standard.set(proteinAmount, forKey: "proteinGoal")
                self.performSegue(withIdentifier: K.calculatorMainSegue, sender: self)
                
                
                
            }
            alert.addAction(gotItAction)
            
            // Present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func proSelected(_ sender: UIButton) {
        performSegue(withIdentifier: K.calculatorProSegue, sender: self)
    }
    
}
