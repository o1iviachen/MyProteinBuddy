//
//  File.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-08-07.
//

import UIKit
import Firebase

class ResultViewController: UIViewController, UITextFieldDelegate, SheetViewControllerDelegate {
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var servingSizeButton: UIButton!
    @IBOutlet weak var mealButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    
    
    var measureQuantity = 0.0
    var foodName = ""
    var proteinAmount = 0
    var descriptionText = ""
    var measureList: [Measure] = []
    var selectedFood: Food? = nil
    var measureDescriptionList: [String] = []
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        servingSizeButton.configurationUpdateHandler = { button in
            if let titleLabel = button.titleLabel {
                DispatchQueue.main.async {
                    titleLabel.numberOfLines = 1
                    titleLabel.lineBreakMode = .byTruncatingTail
                }
            }
        }
        servingTextField.layer.borderColor = UIColor.clear.cgColor
        foodLabel.text = foodName
        servingSizeButton.titleLabel?.lineBreakMode = .byTruncatingTail
        servingSizeButton.titleLabel?.numberOfLines = 1
        
        proteinLabel.text = "\(proteinAmount)g"
        descriptionLabel.text = descriptionText
        progressBar.isHidden = false
        servingTextField.delegate = self
        let defaultServing = "\(measureList[0].measureQuantity) \(measureList[0].measureUnit)"
        servingSizeButton.setTitle(defaultServing, for: .normal)
        if UserDefaults.standard.integer(forKey: "proteinGoal") != 0 {
            DispatchQueue.main.async {
                self.progressLabel.text = "This is \(Int((Float(self.proteinAmount)/Float(UserDefaults.standard.integer(forKey: "proteinGoal"))*100)))% of your daily goal!"
                self.progressBar.progress = Float(self.proteinAmount)/Float(UserDefaults.standard.integer(forKey: "proteinGoal"))
            }
        } else {
            DispatchQueue.main.async {
                self.progressLabel.text = "Please set your protein goal."
                self.progressBar.isHidden = true
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipe() {
        servingTextField.resignFirstResponder()
    }
    
    @objc func handleTap() {
        servingTextField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text  {
            if Double(text) != nil {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // recent add
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        if let servingText = servingTextField.text {
            if servingText.isNumber {

                let servingQuantity = Double(servingTextField.text!)!
                // fix!!!!!!!!!!!!!!!!!!!!!!!
                let food = Food(food: foodLabel.text!, brandName: selectedFood!.brandName, proteinAmount: Int(proteinLabel.text?.dropLast() ?? "0") ?? 0, measures: measureList, consumedAmount: servingQuantity, consumedUnit: servingSizeButton.currentTitle!)
                let mealTitle = mealButton.titleLabel?.text!.lowercased() ?? "breakfast"
                
                let encoder = JSONEncoder()
                if let navigationController = self.navigationController {
                    let viewControllers = navigationController.viewControllers
                    if viewControllers.count <= 2 {
                        // The previous view controller is at index count - 2
                        let previousViewController = viewControllers[viewControllers.count - 1]
                        if type(of: previousViewController) == FoodViewController.self {
                            let dateString = dateFormatter.string(from: date)
                            let encoder = JSONEncoder()
                            do {
                                let foodData = try encoder.encode(selectedFood)
                                if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                                    db.collection("users").document((Auth.auth().currentUser?.email)!).updateData([
                                        dateString: [mealTitle: FieldValue.arrayRemove([foodDictionary])]
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                        }
                                    }
                                }
                            } catch {
                                print("Error encoding food object: \(error)")
                            }
                            
                        }
                    }
                }
                
                db.collection("users").document((Auth.auth().currentUser?.email)!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dateData = document.data()?[dateString] as? [String: Any]
                        
                        // Check if data is not nil
                        if dateData != nil {
                            if var existingOrder = dateData?[mealTitle] as? [[String: Any]] {
                                // Append the new order item
                                do {
                                    let foodData = try encoder.encode(food)
                                    if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                                        existingOrder.append(contentsOf: [foodDictionary])
                                        self.db.collection("users").document((Auth.auth().currentUser?.email)!).updateData([dateString: [mealTitle: existingOrder]]) { error in
                                            if let error = error {
                                                print("Error updating order: \(error)")
                                            } else {
                                                print("Order updated successfully!")
                                            }
                                        }
                                    }
                                } catch {
                                    print("Error encoding food object: \(error)")
                                }
                                
                                
                            } else {
                                
                                do {
                                    let foodData = try encoder.encode(food)
                                    if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                                        print([foodDictionary, foodDictionary])
                                        self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                                            dateString: [mealTitle: FieldValue.arrayUnion([foodDictionary])] // Wrap foodDictionary in an array
                                        ], merge: true) { error in
                                            if let error = error {
                                                print("Error writing document: \(error)")
                                            } else {
                                                print("Document successfully written!")
                                            }
                                        }
                                    }
                                } catch {
                                    print("Error encoding food object: \(error)")
                                }
                                
                            }
                        } else {
                            do {
                                let foodData = try encoder.encode(food)
                                if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                                    self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                                        dateString: [mealTitle: FieldValue.arrayUnion([foodDictionary])] // Wrap foodDictionary in an array
                                    ], merge: true) { error in
                                        if let error = error {
                                            print("Error writing document: \(error)")
                                        } else {
                                            print("Document successfully written!")
                                        }
                                    }
                                }
                            } catch {
                                print("Error encoding food object: \(error)")
                            }
                        }
                    }
                    
                    
                    self.db.collection("users").document((Auth.auth().currentUser?.email)!).getDocument { document, error in
                        if let document = document, document.exists {
                            var recentFoods = document.data()?["recentFoods"] as? [Any] ?? []
                            if recentFoods.count > 10 {
                                recentFoods.removeFirst()
                            }
                            
                            do {
                                let foodData = try encoder.encode(food)
                                
                                if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                                    self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([
                                        "recent_foods": FieldValue.arrayUnion([foodDictionary])], merge: true)
                                    { error in
                                        if let error = error {
                                            print("Error writing document: \(error)")
                                        } else {
                                            print("Document successfully written!")
                                            self.navigationController?.popViewController(animated: true)

                                        }
                                        
                                    }
                                    
                                }
                            } catch {
                                print("Error encoding food object: \(error)")
                            }
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                }

            } else {
                showError(errorMessage: "Please enter a valid number for serving amount.")
            }
        }
        
        
        
    }
    
    
    
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        var valuesToPass: [String] = []
        switch sender {
        case servingSizeButton:
            if !measureList.isEmpty {
                for measure in measureList {
                    let measureUnit = measure.measureUnit
                    let measureQuantity = measure.measureQuantity
                    measureDescriptionList.append("\(measureQuantity) \(measureUnit)")
                    valuesToPass.append("\(measureQuantity) \(measureUnit)")
                }
            } else {
                valuesToPass = ["gram"]
            }
        case mealButton:
            valuesToPass = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        default:
            print("unknown button pressed")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetPresentationController = storyboard.instantiateViewController(withIdentifier: "SheetViewController") as! SheetViewController
        
        // Set the values in the SheetViewController instance
        sheetPresentationController.values = valuesToPass
        sheetPresentationController.delegate = self
        
        
        self.present(sheetPresentationController, animated: true, completion: nil)
    }
    
    func sheetViewController(_ controller: SheetViewController, didSelectValue value: String) {
        if measureDescriptionList.contains(value) {
            print(value)
            servingSizeButton.setTitle(value, for: .normal)
            let relativeWeight = measureList[measureDescriptionList.firstIndex(of: value) ?? 0].relativeWeight
            print(relativeWeight)
            print(measureList[0].relativeWeight)
            let weightRatio = relativeWeight/Double(measureList[0].relativeWeight)
            let proteinAmount = Int(Double(proteinAmount)*weightRatio)
            measureQuantity = Double(servingTextField.text ?? "1")!*measureList[measureDescriptionList.firstIndex(of: value) ?? 0].measureQuantity
            descriptionLabel.text = ("\(selectedFood!.brandName), \(measureQuantity) \(measureList[measureDescriptionList.firstIndex(of: value) ?? 0].measureUnit)")
            proteinLabel.text = "\(proteinAmount)g"
        } else if value.isNumber {
            measureQuantity = Double(servingTextField.text ?? "1")!*measureList[measureDescriptionList.firstIndex(of: value) ?? 0].measureQuantity
            descriptionLabel.text = ("\(selectedFood?.brandName ?? "Common"), \(measureQuantity) \(measureList[measureDescriptionList.firstIndex(of: value) ?? 0].measureUnit)")
            proteinLabel.text = "\(Int(Double(proteinAmount)*Double(value)!))g"
        } else {
            mealButton.setTitle(value, for: .normal)
        }
        // Do something with the selected value
    }
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

protocol SheetViewControllerDelegate: AnyObject {
    func sheetViewController(_ controller: SheetViewController, didSelectValue value: String)
}

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789.")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}

extension UINavigationController {
    var previousViewController: UIViewController? {
        viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
    }
}
