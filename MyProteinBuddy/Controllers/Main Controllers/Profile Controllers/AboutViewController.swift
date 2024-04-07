//
//  AboutViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-08-01.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var informationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Don't call cornerRadius here
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        informationView.cornerRadius(usingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
    }
}

extension UIView {
    func cornerRadius(usingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

