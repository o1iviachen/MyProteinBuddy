//
//  StatsViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-08.
//

import UIKit
import SwiftUI




class StatsViewController: UIViewController {

    
    

    @IBOutlet weak var graphView: UIView!
    
    override func viewDidLoad() {
        let barView = UIHostingController(rootView: BarChartUI())

        addChild(barView)
        graphView.isUserInteractionEnabled = true
        barView.view.isUserInteractionEnabled = true
        graphView.addSubview(barView.view)
        barView.view.frame = graphView.bounds
        
    }
    

    
    
}
