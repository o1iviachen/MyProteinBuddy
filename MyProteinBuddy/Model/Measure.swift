//
//  Measure.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-08-21.
//

import Foundation

struct Measure: Codable, Equatable {
    var measureQuantity: Double
    var measureUnit: String
    var relativeWeight: Double
    static func == (lhs: Measure, rhs: Measure) -> Bool {
            // Compare all relevant properties to determine equality
            return lhs.measureQuantity == rhs.measureQuantity &&
                   lhs.measureUnit == rhs.measureUnit &&
                   lhs.relativeWeight == rhs.relativeWeight
            // Add other properties if needed
        }
}

