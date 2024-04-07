//
//  FoodModel.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-09.
//

import Foundation

struct Food: Codable {
    let food: String
    var brandName: String
    let proteinAmount: Int
    var measures: [Measure]
    let consumedAmount: Double
    let consumedUnit: String
}
