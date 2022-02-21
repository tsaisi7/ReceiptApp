//
//  ProductTableViewCell.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/17.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var discountTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameTextField.isEnabled = false
        countTextField.isEnabled = false
        amountTextField.isEnabled = false
        discountTextField.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
