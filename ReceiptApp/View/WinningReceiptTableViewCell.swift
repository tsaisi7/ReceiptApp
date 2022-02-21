//
//  WinningReceiptTableViewCell.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/20.
//

import UIKit

class WinningReceiptTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var receipt2Label: UILabel!
    @IBOutlet weak var receipt8Label: UILabel!
    @IBOutlet weak var winningMoneyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
