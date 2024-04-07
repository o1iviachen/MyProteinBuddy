//
//  ViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-06-30.
//

import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.signUpSegue, sender: self)
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.logInSegue, sender: self)
    }
    
}

