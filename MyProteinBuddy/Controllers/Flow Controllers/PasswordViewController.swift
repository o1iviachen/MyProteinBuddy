//
//  PasswordViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-08-01.
//

import UIKit
import Firebase

class PasswordViewController: UIViewController {
    override func viewDidLoad() {
        if email != "" {
            emailTextField.text = email
        }
    }
    
    var email = ""
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func sendEmailPressed(_ sender: UIButton) {
        let emailAddress = emailTextField.text
        Auth.auth().sendPasswordReset(withEmail: emailAddress ?? "") { error in
            if let e = error {
                self.showError(errorMessage: e.localizedDescription)
            } else {
                Auth.auth().fetchSignInMethods(forEmail: emailAddress ?? "", completion: {
                    (signInMethods, error) in
                    
                    if let e = error {
                        self.showError(errorMessage: e.localizedDescription)
                    } else {
                        let alert = UIAlertController(title: "Completed!", message: "Please check your email to reset your password.", preferredStyle: .alert)
                        
                        // Add an UIAlertAction with a handler to perform the segue
                        let gotItAction = UIAlertAction(title: "Got It!", style: .default) { (action) in
                            // Perform the segue when the "Got It!" button is tapped
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                        alert.addAction(gotItAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                                               
                )
                
                
            }
            
        }
    }
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
