//
//  SearchViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-19.
//

import UIKit
import FLAnimatedImage
import Firebase
class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIView!
    var logoView: FLAnimatedImageView!
    
    var searchList: [Food] = []
    var measureList: [Measure] = []
    var foodFinder = FoodFinder()
    var selectedFood: Food? = nil
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.resultsTableView.indexPathForSelectedRow {
            self.resultsTableView.deselectRow(at: index, animated: true)
            
            
        }


        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        logoView = FLAnimatedImageView()
        logoView.contentMode = .scaleAspectFit
        let centerX = view.bounds.size.width / 2
        let centerY = view.bounds.size.height / 2
        logoView.frame = CGRect(x: 0, y: 0, width: 200.0, height: 200.0)
        logoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        logoView.center = CGPoint(x: centerX, y: centerY)
        logoView.isHidden = true
        view.addSubview(logoView)
        
        searchTextField.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(UINib(nibName: K.cellFoodName, bundle: nil), forCellReuseIdentifier: K.foodCellIdentifier)
    
        self.fetchRecentFoods()
        
        // Do any additional setup after loading the view.
    }
    
    func fetchRecentFoods() {
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

            let recentData = document.data()?["recent_foods"] as? [[String: Any]]
            // Check if data is not nil
            if let recentData = recentData {

                // Clear the searchList array before appending new data
                    self.searchList.removeAll()

            

                for foodObject in recentData {
                    var measurements: [Measure] = []
                    if let retrievedMeasures = foodObject["measures"] as? [[String: Any]] {
                        for measureValue in retrievedMeasures {
                            let measureQuantity = measureValue["measureQuantity"] as? Double ?? 0.0
                            let measureUnit = measureValue["measureUnit"] as? String ?? ""
                            let relativeWeightValue = measureValue["relativeWeight"] as? Double ?? 0.0
                            let measureObject = Measure(measureQuantity: measureQuantity, measureUnit: measureUnit, relativeWeight: relativeWeightValue)
                            measurements.append(measureObject)
                        }
                    }

                    let foodObject = Food(
                        food: foodObject["food"] as? String ?? "",
                        brandName: foodObject["brandName"] as? String ?? "",
                        proteinAmount: foodObject["proteinAmount"] as? Int ?? 0,
                        measures: measurements,
                        consumedAmount: foodObject["consumedAmount"] as! Double,
                        consumedUnit: foodObject["consumedUnit"] as! String
                    )
                    self.searchList.append(foodObject)
                }

                // Reload the table view on the main thread
                DispatchQueue.main.async {

                    self.scrollView.translatesAutoresizingMaskIntoConstraints = false
                    if let heightConstraintToRemove = self.scrollView.constraints.first(where: { $0.firstAnchor == self.scrollView.heightAnchor }) {
                        // Deactivate the constraint
                        heightConstraintToRemove.isActive = false

                        // Optionally, remove it if it's added as a subview constraint
                        self.scrollView.removeConstraint(heightConstraintToRemove)
                    }
                    self.scrollView.heightAnchor.constraint(equalToConstant: CGFloat(62*self.searchList.count)).isActive = true
                    self.resultsTableView.reloadData()
                }

            } else {
                print("No data found")
            }
        }
    }

    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        if searchTextField.text != "" {
            searchTextField.endEditing(true)
            logoView.isHidden = false
            loadAnimatedGIF()
            
            
            
            
        } else {
            searchTextField.placeholder = "Type a food"
        }
    }
    
    
    func loadAnimatedGIF() {
        guard let gifURL = URL(string: "https://i.pinimg.com/originals/49/23/29/492329d446c422b0483677d0318ab4fa.gif") else {
            print("Invalid GIF URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: gifURL) { [weak self] (data, response, error) in
            if let error = error {
                print("Error loading GIF:", error)
                return
            }
            
            if let data = data, let animatedImage = FLAnimatedImage(animatedGIFData: data) {
                DispatchQueue.main.async {
                    self?.logoView.animatedImage = animatedImage
                }
            } else {
                print("Failed to load GIF data")
            }
        }
        
        task.resume()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            searchTextField.endEditing(true)
            logoView.isHidden = false
            loadAnimatedGIF()
            
            return true
        } else {
            searchTextField.placeholder = "Type a food"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let food = searchTextField.text {
            //            self.searchList.append(contentsOf: [Food(food: "Chicken", amount: "Common, 12g", proteinAmount: 10)])
            //            self.resultsTableView.reloadData()
            self.searchList.removeAll()
            self.resultsTableView.reloadData()
            foodFinder.getFood(foodSearch: food) { foodList in
                self.searchList.removeAll()
                DispatchQueue.main.async {
                    
                    self.scrollView.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Create height constraint using layout anchors
                    if let heightConstraintToRemove = self.scrollView.constraints.first(where: { $0.firstAnchor == self.scrollView.heightAnchor }) {
                        // Deactivate the constraint
                        heightConstraintToRemove.isActive = false

                        // Optionally, remove it if it's added as a subview constraint
                        self.scrollView.removeConstraint(heightConstraintToRemove)
                    }
                    self.scrollView.heightAnchor.constraint(equalToConstant: CGFloat(62*foodList.count)).isActive = true
                    self.searchList = foodList
                    self.logoView.isHidden = true
                    self.resultsTableView.reloadData()
                    
                    // let indexPath = IndexPath(row: self.searchList.count - 1, section: 0)
                    // self.resultsTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
            
            
            
            
        }
        searchTextField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // textfield triggers --> pass reference
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.foodCellIdentifier, for: indexPath) as! FoodCell
        cell.foodName.text = searchList[indexPath.row].food
        cell.foodAmount.text = "\(searchList[indexPath.row].brandName), \(searchList[indexPath.row].measures[0].measureQuantity) \(searchList[indexPath.row].measures[0].measureUnit)"
        cell.proteinAmount.text = "\(searchList[indexPath.row].proteinAmount)g"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFood = searchList[indexPath.row]
        measureList = selectedFood?.measures ?? [Measure(measureQuantity: 1, measureUnit: "gram", relativeWeight: 1.0)]
        performSegue(withIdentifier: K.searchResultSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.searchResultSegue {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.selectedFood = selectedFood
            destinationVC.foodName = selectedFood?.food ?? ""
            destinationVC.proteinAmount = selectedFood?.proteinAmount ?? 0
            destinationVC.descriptionText = "\(selectedFood?.brandName ?? ""), \(selectedFood?.measures[0].measureQuantity ?? 0) \(selectedFood?.measures[0].measureUnit ?? "grams")"
            destinationVC.measureList = measureList
        }
    }
    
}



