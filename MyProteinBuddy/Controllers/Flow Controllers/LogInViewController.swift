//
//  LogInViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-02.
//

import UIKit
import Firebase
import GoogleSignIn
import Charts

class LogInViewController: UIViewController {
    
    
    let db = Firestore.firestore()
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.logInPasswordSegue {
            let destinationVC = segue.destination as! PasswordViewController
            if let email = emailTextfield.text
            {
                destinationVC.email = email
            }
        }
    }
    
    @IBAction func forgotPasswordClicked(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.logInPasswordSegue, sender: self)
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.showError(errorMessage: e.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: K.mainLogInSegue, sender: self)
                }
            }
        }
    }
    
    
    @IBAction func logInWithGoogle(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let e = error {
                showError(errorMessage: e.localizedDescription)
            } else {
                if (result?.user) != nil {
                    let user = result?.user
                    let idToken = user?.idToken?.tokenString
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken!,
                                                                   accessToken: user!.accessToken.tokenString)
                    Auth.auth().signIn(with: credential) { result, error in
                        if let e = error {
                            self.showError(errorMessage: e.localizedDescription)
                        } else {
                            if let isNewUser: Bool = result?.additionalUserInfo?.isNewUser {
                                if isNewUser {
                                    let rawDate = Date()
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd/MM/yyyy"
                                    let date = dateFormatter.string(from: rawDate)
                                    self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                                        date: [:]
                                    ]) { err in
                                        if let err = err {
                                            self.showError(errorMessage: err.localizedDescription)
                                        } else {
                                            self.performSegue(withIdentifier: K.logInCalculatorSegue, sender: self)
                                        }
                                    }
                                } else {
                                    self.performSegue(withIdentifier: K.mainLogInSegue, sender: self)
                                }
                            }
                        }
                        
                    }
                } else {
                    showError(errorMessage: "No user")
                }
                
                
            }
        }
        
        
    }
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}



