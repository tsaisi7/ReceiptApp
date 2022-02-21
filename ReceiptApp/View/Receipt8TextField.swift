//
//  Receipt8TextField.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2022/1/3.
//

import UIKit

class Receipt8TextField: UITextField , UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let disallowedCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let replacementStringIsLegal = string.rangeOfCharacter(from: disallowedCharacterSet) == nil
        return prospectiveText.count <= 8 && replacementStringIsLegal
    }


}
