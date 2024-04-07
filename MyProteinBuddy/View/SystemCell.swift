//
//  SystemCell.swift
//  MyProteinBuddy
//
//  Created by olivia chen on 2023-07-07.
//

import UIKit

class SystemCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
