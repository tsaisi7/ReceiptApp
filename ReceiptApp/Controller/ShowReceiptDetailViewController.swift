//
//  ShowReceiptDetailViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/19.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class ShowReceiptDetailViewController: UIViewController {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var receipt2Label: UILabel!
    @IBOutlet weak var receipt8Label: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //連接storyboard
    
    var receipt: Receipt!
    var receiptID = ""
    var products: [Product] = []
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        readData()
        //從Firestore讀取特定receiptID的詳細資料
        
        tableView.delegate = self
        tableView.dataSource = self
        //設定delegate
    }
    
    func readData(){
        
        self.ref.collection("Receipts").document(receiptID).addSnapshotListener { [self] documentSnapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let document = documentSnapshot{
                print(document.documentID)
                if document.data() != nil {
                    var storeName = document.data()!["storeName"] as? String
                    storeName = storeName == "" ? "商店名稱" : storeName
                    var totalExpense = document.data()!["totalExpense"] as? String
                    totalExpense = totalExpense == "" ? "尚未輸入" : totalExpense
                    storeNameLabel.text = storeName
                    yearLabel.text = document.data()!["year"] as? String
                    monthLabel.text = document.data()!["month"] as? String
                    dayLabel.text = document.data()!["day"] as? String
                    receipt2Label.text = document.data()!["receipt2Number"] as? String
                    receipt8Label.text = document.data()!["receipt8Number"] as? String
                    totalExpenseLabel.text = totalExpense
                    receipt = Receipt(receiptID: receiptID, storeName: storeName, receipt2Number: document.data()!["receipt2Number"] as? String, receipt8Number: document.data()!["receipt8Number"] as? String, year: document.data()!["year"] as? String, month: document.data()!["month"] as? String, day: document.data()!["day"] as? String, totalExpense: totalExpense)
                }
                
            }
        }//讀取發票內容
        self.ref.collection("Receipts").document(receiptID).collection("Products").addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.products = []
                for document in snapshot.documents{
                    self.products.append(Product(productID: document.documentID, name: (document.data()["name"] as? String), count: (document.data()["count"] as? String), amount: (document.data()["amount"] as? String), discount: (document.data()["discount"] as? String)))
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }//讀取發票中商品得內容
    }
    //實作讀取發票、商品內容
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editReceipt"{
            let destinationController = segue.destination as! AddReceiptViewController
            destinationController.receipt2 = receipt.receipt2Number
            destinationController.receipt8 = receipt.receipt8Number
            destinationController.receiptYear = receipt.year
            destinationController.receiptMonth = receipt.month
            destinationController.receiptDay = receipt.day
            destinationController.totalExp = receipt.totalExpense ?? ""
            destinationController.storeName = receipt.storeName ?? ""
            destinationController.receipt = receipt
            destinationController.products = self.products
        }
        // 跳轉到編輯發票頁面時，傳遞發票、商品內容
    }
    

}
extension ShowReceiptDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    //設定cell數
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showProductCell", for: indexPath) as! ShowProductTableViewCell
        cell.nameLabel.text = products[indexPath.row].name
        cell.amountLabel.text = products[indexPath.row].amount
        cell.countLabel.text = products[indexPath.row].count
        cell.discountLabel.text = products[indexPath.row].discount
        return cell
    }
    //設定cell內容
}
