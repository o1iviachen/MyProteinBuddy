import Foundation

struct FoodFinder {
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded",
        "x-app-id": "c1358ca9",
        "x-app-key": "7ecc612b2d7418187f2187710a7da088",
        "x-remote-user-id": "0"
    ]
    
    func getFood(foodSearch: String, completion: @escaping ([Food]) -> Void) {
        var foodList: [Food] = []
        let query = foodSearch
        let url = URL(string: "https://trackapi.nutritionix.com/v2/search/instant")!
        
        let bodyString = "query=\(query)"
        let bodyData = bodyString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([]) // Return an empty array in case of error
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let message = json["message"] as? String {
                            print("Error: \(message)")
                            completion([]) // Return an empty array in case of error
                        } else if let brandedFoods = json["branded"] as? [[String: Any]], let commonFoods = json["common"] as? [[String: Any]] {
                            // Handle brandedFoods and commonFoods to get food names and call getProtein for each
                            var pendingRequests = brandedFoods.count + commonFoods.count
                            for commonFood in commonFoods {
                                if let foodName = commonFood["food_name"] as? String {
                                    self.getProtein(foodName: foodName) { (proteinAmount, measures) in
                                        if let proteinAmount = proteinAmount,
                                           let measures = measures {
                                            let food = Food(food: foodName, brandName: "Common", proteinAmount: proteinAmount, measures: measures, consumedAmount: measures[0].measureQuantity,
                                                            consumedUnit: measures[0].measureUnit)
                                            foodList.append(food)
                                        }
                                        pendingRequests -= 1
                                        if pendingRequests == 0 {
                                            completion(foodList)
                                        }
                                    }
                                }
                            }
                            for brandedFood in brandedFoods {
                                if let foodName = brandedFood["food_name"] as? String {
                                    self.getProtein(foodName: foodName) { (proteinAmount, measures) in
                                        if let proteinAmount = proteinAmount,
                                           let measures = measures {
                                            
                                            let food = Food(food: foodName, brandName: brandedFood["brand_name"] as! String, proteinAmount: proteinAmount, measures: measures, consumedAmount: measures[0].measureQuantity,
                                                            consumedUnit: measures[0].measureUnit)
                                            
                                            foodList.append(food)
                                        }
                                        pendingRequests -= 1
                                        if pendingRequests == 0 {
                                            completion(foodList)
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion([]) // Return an empty array in case of error
                }
            }
        }
        task.resume()
    }
    
    func getProtein(foodName: String, completion: @escaping (Int?, [Measure]?) -> Void) {
        let query = foodName
        let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!
        
        let bodyString = "query=\(query)"
        let bodyData = bodyString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, nil) // Return optional values in case of error
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let message = json["message"] as? String {
                            print("\(message)")
                            completion(nil, nil) // Return optional values in case of error
                        } else if let foods = json["foods"] as? [[String: Any]], let firstFood = foods.first {
                            if let protein = firstFood["nf_protein"] as? Double,
                               let servingSize = firstFood["serving_weight_grams"] as? Double {
                                var measureList: [Measure] = []
                                if let altMeasures = firstFood["alt_measures"] as? [[String: Any]] {
                                    for altMeasure in altMeasures {
                                        
                                        if let measureNumber = altMeasure["qty"] as? Int,
                                           let measureUnit = altMeasure["measure"] as? String,
                                           let equivalentMeasure = altMeasure["serving_weight"] as? Double {
                                            let measure = Measure(measureQuantity: Double(measureNumber), measureUnit: measureUnit, relativeWeight: equivalentMeasure)
                                            measureList.append(measure)
                                        }
                                        
                                    }
                                    
                                }
                                measureList.insert(Measure(measureQuantity: servingSize, measureUnit: "grams", relativeWeight: Double(servingSize)), at: 0)
                                completion(Int(protein), measureList)
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion(nil, nil) // Return optional values in case of error
                }
            }
        }
        task.resume()
    }
}
