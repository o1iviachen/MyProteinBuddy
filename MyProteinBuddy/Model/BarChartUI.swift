//
//  BarChartUI.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-27.
//
import SwiftUI
import Charts
import Firebase

var globalFetchedData: [Intake] = []

func fetchDataForDate(startDate: Int, endDate: Int, completion: @escaping ([Intake]) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yy_MM_dd"
    let date = Date()
    let db = Firestore.firestore()
    
    var fetchedData: [Intake] = []
    
    
    for num in startDate...endDate {
        let previousDate = date.getDayBefore(number: num)
        let previousDateString = dateFormatter.string(from: previousDate)
        
        
        
        let docRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        
        docRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                // Leave the dispatch group on error
                return
            }
            
            guard let documentData = documentSnapshot?.data() else {
                print("Document was empty.")
                // Leave the dispatch group when data is not available
                return
            }
            
            if let dateData = documentData[previousDateString] as? [String: Any] {
                let mealNames = ["breakfast", "lunch", "dinner", "snacks"]
                var intakeTotal = 0
                
                for meal in mealNames {
                    if let foods = dateData[meal] as? [[String: Any]] {
                        for food in foods {
                            intakeTotal += food["proteinAmount"] as? Int ?? 0
                        }
                    }
                }
                
                let intake = Intake(date: previousDate, count: intakeTotal)
                fetchedData.append(intake)
            } else {
                fetchedData.append(Intake(date: previousDate, count: 0))
            }
            completion(fetchedData)

        }

    }

    
}




extension Date {
    func getDayBefore(number: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -number, to: self)!
    }
}


struct BarChartUI: View {
    
    var options = ["7 Days", "Last Week", "Last Month"]
    
    @State var didAppear = false
    @State private var currentTab: String = "7 Days"
    @State var sample_data: [Intake] = globalFetchedData
    @State private var currentActiveItem: Intake?
    @State private var plotWidth: CGFloat = 0
    
    var body: some View {
        NavigationView {
            
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("", selection: $currentTab) {
                        Text("7 Days").tag("7 Days")
                        Text("Last Week").tag("Last Week")
                        Text("Last Month").tag("Last Month")
                        
                    }
                    .pickerStyle(.segmented)
                    
                    
                    let totalValue = sample_data.reduce(0.0) { partialResult, item in
                        Double(item.count) + partialResult
                    }
                    if sample_data.count > 0 {
                        let averageValue = totalValue / Double(sample_data.count)
                  
                        Text("Average intake: \(String(format: "%.1f", averageValue))")
                            .fontWeight(.semibold)
                    }
                    AnimatedChart()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.shadow(.drop(radius: 2)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .background(Color(uiColor: UIColor(red: 1, green: 0.9411764705882353, blue: 0.8588235294117647, alpha: 1)))
            
            .navigationTitle("Protein Intake")
            .onAppear {
                
                    fetchDataForDate(startDate: 0, endDate: 30, completion: {fetchedData in
                        globalFetchedData = fetchedData
                        if globalFetchedData.count == 31
                        {
                            if currentTab == "7 Days" {
                                sample_data = Array(globalFetchedData[0...7])
                                animateGraph(fromChange: true)
                            } else if currentTab == "Last Week" {
                                sample_data = Array(globalFetchedData[7...14])
                                animateGraph(fromChange: true)
                            }
                            
                            else {
                                sample_data = Array(globalFetchedData[0...30])
                                animateGraph(fromChange: true)
                            }
                        }
                    })
             
                    
                    
                
            }
            .onChange(of: currentTab) { newValue in
                DispatchQueue.main.async {
                    if newValue == "7 Days" {
                        sample_data = Array(globalFetchedData[0...7])
                        animateGraph(fromChange: true)
                    } else if newValue == "Last Week" {
                        sample_data = Array(globalFetchedData[7...14])
                        animateGraph(fromChange: true)
                    }
                    
                    else {
                        sample_data = Array(globalFetchedData[0...30])
                        animateGraph(fromChange: true)
                    }
                }

                
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = sample_data.max { item1, item2 in
            return item2.count > item1.count
        }?.count ?? 0
        
        Chart {
            ForEach(sample_data) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Grams", item.animate ? item.count : 0)
                )
                .foregroundStyle(Color(uiColor: UIColor(red: 0.4, green: 0.2, blue: 0, alpha: 1)))
                
                if let currentActiveItem = currentActiveItem, currentActiveItem.id == item.id {
                    RuleMark(x: .value("Grams", currentActiveItem.count))
                        .offset(x: (plotWidth / CGFloat(sample_data.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Grams")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(String(currentActiveItem.count))
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
            }
        }
        .chartYScale(domain: 0...(max + max / 2))
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    let date = calendar.component(.day, from: date)
                                    if let currentItem = sample_data.first(where: { item in
                                        calendar.component(.day, from: item.date) == date
                                    }) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                                }
                            }
                            .onEnded { value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            animateGraph(fromChange: false)
        }
    }
    
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in sample_data.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
          
                    sample_data[index].animate = true
                }
            }
        }
    }
   

}

struct BarChartUI_Previews: PreviewProvider {
    static var previews: some View {
        BarChartUI()
    }
}
