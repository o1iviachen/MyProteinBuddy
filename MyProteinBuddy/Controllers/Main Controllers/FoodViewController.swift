//
//  FoodViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-08.
//

import UIKit
import Firebase

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate & UINavigationControllerDelegate {
    
    var tableData: [[Food]] = [[], [], [], []]
    var selectedFood: Food? = nil
    var measureList: [Measure] = []
    let headerTitles = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    var intakeTotal = 0
    let date = Date()
    let dateFormatter = DateFormatter()
    let userDefaults = UserDefaults.standard
    
    
    
    @IBOutlet weak var intakeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainView: UIView!
    @IBAction func addFoodPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.searchSegue, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dateFormatter.dateFormat = "YY_MM_dd"
        let dateString = dateFormatter.string(from: date)
        fetchDataForDate(dateString: dateString)
        DispatchQueue.main.async {

            self.mainView.translatesAutoresizingMaskIntoConstraints = false
            if let heightConstraintToRemove = self.mainView.constraints.first(where: { $0.firstAnchor == self.mainView.heightAnchor }) {
                // Deactivate the constraint
                heightConstraintToRemove.isActive = false

                // Optionally, remove it if it's added as a subview constraint
                self.mainView.removeConstraint(heightConstraintToRemove)
            }
            if CGFloat(62*self.tableData.count + 40) > CGFloat(UIScreen.main.bounds.size.height) {
                print(62*self.tableData.count + 40)
                self.mainView.heightAnchor.constraint(equalToConstant: CGFloat(62*self.tableData.count + 40)).isActive = true
                self.tableView.reloadData()
            } 
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellFoodName, bundle: nil), forCellReuseIdentifier: K.foodCellIdentifier)
        tableView.separatorStyle = .singleLine
        dateFormatter.dateFormat = "YY_MM_dd"
        
    }
    
    func fetchDataForDate(dateString: String) {
        let docRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        docRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document was empty.")
                return
            }
            self.intakeTotal = 0
            let dateData = document.data()?[dateString] as? [String: Any]
            self.tableData = [[],[],[],[]]
            // Check if data is not nil
            if dateData != nil {
                // Clear the existing table data
                let mealNames = ["breakfast", "lunch", "dinner", "snacks"]
                for meal in mealNames {
                    if let foods = dateData?[meal] as? [[String: Any]] {
                        for food in foods {
                            var measurements: [Measure] = []
                            if let retrievedMeasures = food["measures"] as? [AnyObject] {
                                for measurement in retrievedMeasures {
                                    if let measureValue = measurement as? [String: Any] {
                                        let measureQuantity = measureValue["measureQuantity"] as! Double
                                        let measureUnit = measureValue["measureUnit"] as! String
                                        let relativeWeightValue = measureValue["relativeWeight"] as! Double
                                        let measureObject = Measure(measureQuantity: measureQuantity, measureUnit: measureUnit, relativeWeight: relativeWeightValue)
                                        
                                        measurements.append(measureObject)
                                        
                                    }
                                    
                                }
                            }
                            self.intakeTotal += food["proteinAmount"] as! Int
                            let foodObject = Food(
                                food: food["food"] as? String ?? "",
                                brandName: food["brandName"] as? String ?? "",
                                proteinAmount: food["proteinAmount"] as? Int ?? 0,
                                measures: measurements,
                                consumedAmount: food["consumedAmount"] as! Double,
                                consumedUnit: food["consumedUnit"] as! String
                            )
                            self.tableData[mealNames.firstIndex(of: meal)!].append(foodObject)
                        }
                    }
                }
                
                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    
                }
            } else {
                print("No data found for \(dateString)")
            }
            
            let remainingIntake = UserDefaults.standard.integer(forKey: "proteinGoal") - self.intakeTotal
            if remainingIntake > 0 {
                self.intakeLabel.text = "\(self.intakeTotal) grams out \(UserDefaults.standard.integer(forKey: "proteinGoal")) grams. \(remainingIntake) to go!"
                self.progressView.progress = Float(self.intakeTotal)/Float(UserDefaults.standard.integer(forKey: "proteinGoal"))
            } else {
                self.intakeLabel.text = "\(self.intakeTotal) grams out \(UserDefaults.standard.integer(forKey: "proteinGoal")) grams. 0 to go!"
                self.progressView.progress = 1.0
            }
        }
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellText = tableData[indexPath.section][indexPath.row].food
        let cellSize = "\(tableData[indexPath.section][indexPath.row].brandName), \(tableData[indexPath.section][indexPath.row].consumedAmount) x \(tableData[indexPath.section][indexPath.row].consumedUnit)"
        let cellProtein = tableData[indexPath.section][indexPath.row].proteinAmount
        let cell = tableView.dequeueReusableCell(withIdentifier: K.foodCellIdentifier, for: indexPath) as! FoodCell
        cell.foodName.text = cellText
        cell.foodAmount.text = cellSize
        cell.proteinAmount.text = "\(cellProtein)g"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFood = tableData[indexPath.section][indexPath.row]
        measureList = selectedFood?.measures ?? [Measure(measureQuantity: 1, measureUnit: "gram", relativeWeight: 1.0)]
        selectedFood = tableData[indexPath.section][indexPath.row]
        dateFormatter.dateFormat = "YY_MM_dd"
        
        performSegue(withIdentifier: K.foodEditSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.foodEditSegue {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.selectedFood = selectedFood
            destinationVC.foodName = selectedFood?.food ?? ""
            destinationVC.proteinAmount = selectedFood?.proteinAmount ?? 0
            destinationVC.descriptionText = "\(selectedFood?.brandName ?? ""), \(selectedFood?.measures[0].measureQuantity ?? 0) \(selectedFood?.measures[0].measureUnit ?? "grams")"
            destinationVC.measureList = measureList
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        selectedFood = tableData[indexPath.section][indexPath.row]
        var deleted = false
        DispatchQueue.main.async {
            if editingStyle == .delete && deleted == false {
                print("hello")
                //self.deleteFood(food: self.selectedFood!, mealTitle: self.headerTitles[indexPath.section])

                self.tableData[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                deleted = true
            }
        }
        
    }
    
    func deleteFood(food: Food, mealTitle: String) {
        
               dateFormatter.dateFormat = "YY_MM_dd"
               let dateString = dateFormatter.string(from: date)
               let encoder = JSONEncoder()
               do {
                   let foodData = try encoder.encode(selectedFood)
                   if let foodDictionary = try JSONSerialization.jsonObject(with: foodData, options: []) as? [String: Any] {
                       print(foodDictionary)
                       db.collection("users").document((Auth.auth().currentUser?.email)!).updateData([
                           dateString: [mealTitle: FieldValue.arrayRemove([foodDictionary])]
                       ]) { err in
                           if let err = err {
                               print("Error updating document: \(err)")
                           } else {
                               print("Document successfully updated!")
                           }
                       }
       
                   }
               } catch {
                   print("Error encoding food object: \(error)")
               }
    }
    
    
}

