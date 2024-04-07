//
//  SheetViewController.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-08-16.
//

import UIKit

class SheetViewController: UIViewController, UISheetPresentationControllerDelegate, CustomDatePickerDelegate {
    weak var delegate: SheetViewControllerDelegate?

    func didSelectValue(_ value: String) {
        delegate?.sheetViewController(self, didSelectValue: value)
    }
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var values: [String] = [] // Declare the instance variable for values
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the values array you received from ResultViewController
        let customDatePicker = CustomDatePicker(frame: CGRect(), values: values)
        customDatePicker.translatesAutoresizingMaskIntoConstraints = false
        sheetPresentationController.delegate = self
        sheetPresentationController.selectedDetentIdentifier = .medium
        let multiplier = 0.25
        let fraction = UISheetPresentationController.Detent.custom { context in
            // height is the view.frame.height of the view controller which presents this bottom sheet
            self.view.bounds.size.height * multiplier
        }
        sheetPresentationController.detents = [fraction]
        view.addSubview(customDatePicker)
        
        customDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        customDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        customDatePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        customDatePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        
        // Center vertically (adjust the constant as needed)
        customDatePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        customDatePicker.delegate = self
    }
}


protocol CustomDatePickerDelegate: AnyObject {
    func didSelectValue(_ value: String)
}

class CustomDatePicker: UIView {
    
    weak var delegate: CustomDatePickerDelegate?
    
    private var pickerView: UIPickerView!
    private var values: [String] = []
    
    init(frame: CGRect, values: [String]) {
        super.init(frame: frame)
        self.values = values
        
        pickerView = UIPickerView(frame: CGRect())
        pickerView.delegate = self
        pickerView.dataSource = self
        
        addSubview(pickerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomDatePicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = values[row]
        delegate?.didSelectValue(selectedValue)
    }
}


