//
//  AddProductViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/16.
//

import UIKit

protocol AddProductViewControllerDelegate {
    
    func addProductViewController(_ controller: AddProductViewController, didSelect product: Product)
}
//建立新增商品的protocol，並逆向傳值

class AddProductViewController: UIViewController {
    
    var product: Product!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var discountTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            addButton.layer.cornerRadius = 5
        }
    }
    //連接storyboard
    
    var delegate: AddProductViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    func alertMessage(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okActioin)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveProduct(){
        
        guard let name = nameTextField.text, name != "", let count = countTextField.text, count != "", let amount = amountTextField.text, amount != "", let discount = discountTextField.text, discount != "" else {
            alertMessage(title: "提醒", message: "請輸入所有資料")
            return
        }
        if product == nil{
            product = Product(name: name, count: count, amount: amount, discount: discount)
        }else{
            product = Product(productID: product.productID, name: name, count: count, amount: amount, discount: discount)
        }
        delegate?.addProductViewController(self, didSelect: product)
        navigationController?.popViewController(animated: true)
        //建立商品逆向傳值並返回建立發票頁面
    }
    //實作建立商品
}

