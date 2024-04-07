//
//  SignUpViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-02.
//

import UIKit
import Firebase
import GoogleSignIn

class SignUpViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    let db = Firestore.firestore()
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.showError(errorMessage: e.localizedDescription)
                } else {
                    let rawDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd_MM_yyyy"
                    let date = dateFormatter.string(from: rawDate)
                    self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                        
                        date: [:]
                    ]) { err in
                        if let err = err {
                            self.showError(errorMessage: err.localizedDescription)
                        } else {
                            self.performSegue(withIdentifier: K.signUpCalculatorSegue, sender: self)
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
    @IBAction func signUpWithGoogle(_ sender: GIDSignInButton) {
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
                                    if let isNewUser: Bool = result?.additionalUserInfo?.isNewUser {
                                        if isNewUser {
                                            self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                                                date: [:]
                                            ]) { err in
                                                if let err = err {
                                                    self.showError(errorMessage: err.localizedDescription)
                                                } else {
                                                    self.performSegue(withIdentifier: K.signUpCalculatorSegue, sender: self)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.performSegue(withIdentifier: K.mainSignUpSegue, sender: self)
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
