//
//  EditReceiptViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/19.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth


class EditReceiptViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var receipt2TextField: UITextField!
    @IBOutlet weak var receipt8TextField: UITextField!
    @IBOutlet weak var totalExpenseTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            addButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var updateButton: UIButton!{
        didSet{
            updateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var deleteButton: UIButton!{
        didSet{
            deleteButton.layer.cornerRadius = 5
        }
    }
    //連接storyboard
    
    var receipt: Receipt!
    var products: [Product]!
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeNameTextField.text = receipt.storeName
        receipt2TextField.text = receipt.receipt2Number
        receipt8TextField.text = receipt.receipt8Number
        yearTextField.text = receipt.year
        monthTextField.text = receipt.month
        dayTextField.text = receipt.day
        totalExpenseTextField.text = receipt.totalExpense
        //預設輸入格內容
        
        tableView?.delegate = self
        tableView?.dataSource = self
        receipt8TextField.delegate = self
        receipt2TextField.delegate = self
        yearTextField.delegate = self
        monthTextField.delegate = self
        dayTextField.delegate = self
        //設定各種delegate
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    @IBAction func UpdateReceipt(){
        if let storeName = storeNameTextField.text, let receipt2Number = receipt2TextField.text, let receipt8Number = receipt8TextField.text, let totalExpense = totalExpenseTextField.text, let year = yearTextField.text, let month = monthTextField.text, let day = dayTextField.text{
            if receipt2Number != "" && receipt8Number != "" && year != "" && month != "" && day != ""{
                switch month{
                    case "01","03","05","07","08","10","12":
                        if  Int(day)! > 31 || Int(day)! < 1 {
                            let alertController = UIAlertController(title: "提醒", message: "請輸入有效日期", preferredStyle: .alert)
                            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okActioin)
                            present(alertController, animated: true, completion: nil)
                            return
                        }
                    case "04","06","09","11":
                        if  Int(day)! > 30 || Int(day)! < 1 {
                            let alertController = UIAlertController(title: "提醒", message: "請輸入有效日期", preferredStyle: .alert)
                            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okActioin)
                            present(alertController, animated: true, completion: nil)
                            return
                        }
                    case "02":
                        if  Int(day)! > 29 || Int(day)! < 1 {
                            let alertController = UIAlertController(title: "提醒", message: "請輸入有效日期", preferredStyle: .alert)
                            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okActioin)
                            present(alertController, animated: true, completion: nil)
                            return
                        }
                    default:
                        let alertController = UIAlertController(title: "提醒", message: "請輸入有效日期", preferredStyle: .alert)
                        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okActioin)
                        present(alertController, animated: true, completion: nil)
                        return
                }
                //判斷輸入日期是否有效
                
                let receiptData = ["storeName": storeName, "receipt2Number": receipt2Number, "receipt8Number": receipt8Number, "year": year, "month": month, "day": day, "totalExpense": totalExpense] as [String: Any]
                ref.collection("Receipts").document(receipt.receiptID!).updateData(receiptData){ (error) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }else{
                        print("Receipt updated")
                        for product in self.products {
                            let productID = product.productID == nil ? UUID().uuidString : product.productID
                            let productData = ["productID": productID!, "name": product.name!, "count": product.count!, "amount": product.amount!, "discount": product.discount! ] as [String: Any]
                            print(product.productID as Any)
                            if product.productID == nil{
                                self.ref.collection("Receipts").document(self.receipt.receiptID!).collection("Products").document(productID!).setData(productData){ (error) in
                                    if let error = error{
                                        print(error.localizedDescription)
                                        return
                                    }else{
                                        print("Product uploaded")
                                    }
                                }
                            }else{
                                self.ref.collection("Receipts").document(self.receipt.receiptID!).collection("Products").document(productID!).updateData(productData){ (error) in
                                    if let error = error{
                                        print(error.localizedDescription)
                                        return
                                    }else{
                                        print("Product updated")
                                    }
                                }
                            }
                        }
                        let alertController = UIAlertController(title: "成功", message: "發票更新成功", preferredStyle: .alert)
                        let okActioin = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(okActioin)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                //上傳發票及發票中的商品
            }else {
                let alertController = UIAlertController(title: "提醒", message: "請輸入必填資料", preferredStyle: .alert)
                let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActioin)
                present(alertController, animated: true, completion: nil)
            }//檢查必填的輸入格
        }
        //實作上傳發票
    }
    //實作更新發票內容
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAddProduct"{
            let addProductViewController = segue.destination as? AddProductViewController
            addProductViewController?.delegate = self
        }
        // 跳轉到編輯的新增商品頁面，設定delegate
        
        if segue.identifier == "editUpdateProduct"{
            let updateProductViewController = segue.destination as? UpdateProductViewController
            updateProductViewController?.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow{
                updateProductViewController?.indexPath = indexPath
                updateProductViewController?.product = products[indexPath.row]
            }
        }
        //跳轉到編輯更新商品頁面，傳遞商品內容
    }
    
}
extension EditReceiptViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    //設定cell數
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "eidtProductCell", for: indexPath) as! ProductTableViewCell
        cell.nameTextField.text = products[indexPath.row].name
        cell.countTextField.text = products[indexPath.row].count
        cell.amountTextField.text = products[indexPath.row].amount
        cell.discountTextField.text = products[indexPath.row].discount
        return cell
    }
    //設定cell內容
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
            
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            self.products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    //實作往左滑刪除商品
}
extension EditReceiptViewController: AddProductViewControllerDelegate{
    func addProductViewController(_ controller: AddProductViewController, didSelect product: Product) {
        products.append(product)
        tableView.reloadData()
    }
    //接收新增商品頁面逆向傳回建立發票頁面的內容
}
extension EditReceiptViewController: UpdateProductViewControllerDelegate{
    func updateProductViewController(_ controller: UpdateProductViewController, didSelect product: Product, indexPath: IndexPath) {
        products[indexPath.row] = product
        tableView.reloadData()
    }
    //接收新更新品頁面逆向傳回建立發票頁面的內容
}
extension EditReceiptViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if receipt2TextField == textField{
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let disallowedCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            let replacementStringIsLegal = string.rangeOfCharacter(from: disallowedCharacterSet) == nil
            
            return prospectiveText.count <= 2 && replacementStringIsLegal
        }//只能輸入英文及兩個字
        
        if monthTextField == textField{
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.count <= 2
        }//只能輸入兩個字
        
        if dayTextField == textField{
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)

            return prospectiveText.count <= 2
        }//只能輸入兩個字
        
        if receipt8TextField == textField{
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.count <= 8
        }//只能輸入八個字
        
        if yearTextField == textField{
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.count <= 3
        }//只能輸入三個字
        
        return true
    }
    //對UITextField 的各種輸入限制
}
