//
//  WinningReceiptDetailViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class WinningReceiptDetailViewController: UIViewController {
    
    @IBOutlet weak var winningMoneyLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var receipt2Label: UILabel!
    @IBOutlet weak var receipt8Label: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //連接storyboard
    
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    var receipt: Receipt!
    var winningMoney: String!
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        winningMoneyLabel.text = winningMoney
        storeNameLabel.text = receipt.storeName
        yearLabel.text = receipt.year
        monthLabel.text = receipt.month
        dayLabel.text = receipt.day
        receipt2Label.text = receipt.receipt2Number
        receipt8Label.text = receipt.receipt8Number
        totalExpenseLabel.text = receipt.totalExpense
        //預設輸入格內容
        
        getProducts()
        //讀取商品內容
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    func getProducts(){
        
        self.ref.collection("Receipts").document(self.receipt.receiptID).collection("Products").getDocuments { snapshot, error in
        if let error = error{
            print(error.localizedDescription)
        }
        if let snapshot = snapshot{
            self.products = []
            for document in snapshot.documents{
            self.products.append(Product(productID: document.documentID, name: (document.data()["name"] as? String), count: (document.data()["count"] as? String), amount: (document.data()["amount"] as? String), discount: (document.data()["discount"] as? String)))
            print("products loaded")

            }
            print("----\(self.products)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        }
    }
    //實作讀取商品內容
}
extension WinningReceiptDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
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
