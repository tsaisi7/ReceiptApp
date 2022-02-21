//
//  AddReceiptViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFirestore

class AddReceiptViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var yearTextField: YearTextField!
    @IBOutlet weak var monthTextField: MonthTextField!
    @IBOutlet weak var dayTextField: DayTextField!
    @IBOutlet weak var receipt2TextField: Receipt2TextField!
    @IBOutlet weak var receipt8TextField: Receipt8TextField!
    @IBOutlet weak var totalExpenseTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            addButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var updateButton: UIButton!{
        didSet{
            updateButton.layer.cornerRadius = 5
        }
    }
    // 連接storyboard
    
    var receipt: Receipt!
    var products: [Product] = []
    var storeName = ""
    var receipt2 = ""
    var receipt8 = ""
    var receiptYear = ""
    var receiptMonth = ""
    var receiptDay = ""
    var totalExp = ""
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    var IDs: [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        storeNameTextField.text = storeName
        receipt2TextField.text = receipt2
        receipt8TextField.text = receipt8
        yearTextField.text = receiptYear
        monthTextField.text = receiptMonth
        dayTextField.text = receiptDay
        totalExpenseTextField.text = totalExp
        //從掃描得到的資料，並預設在各個欄位中
        
        tableView?.delegate = self
        tableView?.dataSource = self
        //各種delegate
        
        ref.collection("Receipts").addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot{
                for document in snapshot.documents{
                    self.IDs.append(document.documentID)
                }
            }
        }
        //取得Firestore中Receipts的所有ID，之後判斷發票是否已儲存
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    func alertMessage(title: String, message: String, handler: ((UIAlertAction) -> Void)?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okActioin)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func saveReceipt(){

    guard let storeName = storeNameTextField.text, storeName != "", let receipt2Number = receipt2TextField.text, receipt2Number != "", let receipt8Number = receipt8TextField.text, receipt8Number != "", let totalExpense = totalExpenseTextField.text, totalExpense != "", let year = yearTextField.text, year != "", let month = monthTextField.text, month != "", let day = dayTextField.text , day != "" else {
                print("ERROR")
                self.alertMessage(title: "提醒", message: "請輸入必填資料", handler: nil)
                return
            }
       //guard let 做 optional binding
        
        let dateString = String(Int(year)! + 1911) + ":" + month + ":" + day
        print(dateString)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd"
        if dateFormatter.date(from: dateString) == nil{
            alertMessage(title: "提醒", message: "請輸入有效日期", handler: nil)
            return
        }
        //判斷輸入日期是否有效
        
        let receiptID = receipt2Number + "-" + receipt8Number
        for ID in self.IDs{
            if ID == receiptID{
                alertMessage(title: "提醒", message: "發票已儲存過了", handler: nil)
                return
            }
        }
        //檢查發票使否已經儲存了
        
        let receiptData = ["receiptID": receiptID,"storeName": storeName, "receipt2Number": receipt2Number, "receipt8Number": receipt8Number, "year": year, "month": month, "day": day, "totalExpense": totalExpense] as [String: Any]
        ref.collection("Receipts").document(receiptID).setData(receiptData){ (error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("Receipt uploaded")
                for product in self.products {
                    let productID = UUID().uuidString
                    let productData = ["productID": productID,"name": product.name!, "count": product.count!, "amount": product.amount!, "discount": product.discount! ] as [String: Any]
                    self.ref.collection("Receipts").document(receiptID).collection("Products").addDocument(data: productData){ (error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }else{
                            print("Product uploaded")
                        }
                    }
                }
                self.alertMessage(title: "成功", message: "發票上傳成功") { UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        //上傳發票及發票中的商品
    }
    
    @IBAction func updateReceipt(){
        guard let storeName = storeNameTextField.text, let receipt2Number = receipt2TextField.text, receipt2Number != "", let receipt8Number = receipt8TextField.text, receipt8Number != "", let totalExpense = totalExpenseTextField.text, let year = yearTextField.text, year != "", let month = monthTextField.text, month != "", let day = dayTextField.text, day != "" else {
                print("ERROR")
                self.alertMessage(title: "提醒", message: "請輸入必填資料", handler: nil)
                return
            }
            //利用switch 驗證必填的輸入格，guard let 做 optional binding
            
            let dateString = String(Int(year)! + 1911) + ":" + month + ":" + day
            print(dateString)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd"
            if dateFormatter.date(from: dateString) == nil{
                alertMessage(title: "提醒", message: "請輸入有效日期", handler: nil)
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
        //檢查必填的輸入格
        //實作上傳發票
        // 寫一個 alertMessage()來減少重複程式碼、判斷有效日期改用 dateFormatter 來驗證、用switch 跟 guard let 來減少巢狀層數
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addProduct"{
            let addProductViewController = segue.destination as? AddProductViewController
            addProductViewController?.delegate = self
        }
        // 跳轉到新稱商品頁面時，設置delegate
        
        if segue.identifier == "updateProduct"{
            let updateProductViewController = segue.destination as? UpdateProductViewController
            updateProductViewController?.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow{
                updateProductViewController?.indexPath = indexPath
                updateProductViewController?.product = products[indexPath.row]
            }
        }
        // 跳轉到更新商品頁面時，設置delegate、將所需更新的商品內容傳過去
        
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
extension AddReceiptViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    //設定cell數量
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        cell.nameTextField.text = products[indexPath.row].name
        cell.countTextField.text = products[indexPath.row].count
        cell.amountTextField.text = products[indexPath.row].amount
        cell.discountTextField.text = products[indexPath.row].discount
        return cell
    }
    //設定cell的內容
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
            
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            
            self.ref.collection("Receipts").document(self.receipt.receiptID!).collection("Products").document(self.products[indexPath.row].productID).delete()
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
extension AddReceiptViewController: AddProductViewControllerDelegate{
    
    func addProductViewController(_ controller: AddProductViewController, didSelect product: Product) {
        
        products.append(product)
        tableView.reloadData()
    }
    //接收新增商品頁面逆向傳回建立發票頁面的內容
}
extension AddReceiptViewController: UpdateProductViewControllerDelegate{
    
    func updateProductViewController(_ controller: UpdateProductViewController, didSelect product: Product, indexPath: IndexPath) {
        
        products[indexPath.row] = product
        tableView.reloadData()
    }
    //接收新更新品頁面逆向傳回建立發票頁面的內容
}

