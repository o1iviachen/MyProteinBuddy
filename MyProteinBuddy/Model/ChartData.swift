//
//  ChartData.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-27.
//

import Foundation

struct Intake: Identifiable {
    var date: Date
    var count: Int
    var id = UUID().uuidString
    var animate: Bool = false
}

extension Date {
    func updateDate(value: Int)->Date{
        let calendar = Calendar.current
        return calendar.date(bySetting: .day, value: value, of: self) ?? .now
        //return calendar.date(bySettingHour:value, minute:0, second:0, of: self) ?? .now
    }
}


