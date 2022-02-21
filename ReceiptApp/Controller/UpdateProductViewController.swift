//
//  UpdateProductViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/17.
//

import UIKit

protocol UpdateProductViewControllerDelegate {
    
    func updateProductViewController(_ controller: UpdateProductViewController, didSelect product: Product, indexPath: IndexPath)
}
//建立更新商品的protocol，並逆向傳值

class UpdateProductViewController: UIViewController {

    var product: Product!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var discountTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!{
        didSet{
            updateButton.layer.cornerRadius = 5
        }
    }
    //連接storyboard
    
    var delegate: UpdateProductViewControllerDelegate?
    var indexPath: IndexPath!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        nameTextField.text = product.name
        countTextField.text = product.count
        amountTextField.text = product.amount
        discountTextField.text = product.discount
        //預設輸入格內容
        
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
    
    @IBAction func updateProduct(){
        
        guard let name = nameTextField.text, name != "", let count = countTextField.text, count != "", let amount = amountTextField.text, amount != "", let discount = discountTextField.text, discount != "" else {
            alertMessage(title: "提醒", message: "請輸入所有資料")
            return
        }
        if product == nil{
            product = Product(name: name, count: count, amount: amount, discount: discount)
        }else{
            product = Product(productID: product.productID, name: name, count: count, amount: amount, discount: discount)
        }
        delegate?.updateProductViewController(self, didSelect: product, indexPath: indexPath)
        navigationController?.popViewController(animated: true)
        //更新商品逆向傳值並返回建立發票頁面
    }
    //實作更新商品
}
