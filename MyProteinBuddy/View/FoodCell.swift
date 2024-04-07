//
//  FoodCell.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-08.
//

import UIKit

class FoodCell: UITableViewCell {

    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodAmount: UILabel!
    @IBOutlet weak var proteinAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
