//
//  ShowReceiptBySearchViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class ShowReceiptBySearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    //連接storyboard
    
    var receipts: [Receipt] = []
    var products: [Product] = []
    var searchReceipts: [Receipt] = []
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
        //讀取發票資料
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //設定各種delegate
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.text = ""
        searchReceipts = []
        tableView.reloadData()
    }
    
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func readData(){

        self.ref.collection("Receipts").addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.receipts = []
                for document in snapshot.documents{
                    self.ref.collection("Receipts").document(document.documentID).collection("Products").getDocuments { snapshot, error in
                        if let error = error{
                            print(error.localizedDescription)
                        }
                        if let snapshot = snapshot{
                            self.products = []
                            for document in snapshot.documents{
                                self.products.append(Product(productID: document.documentID, name: (document.data()["name"] as? String), count: (document.data()["count"] as? String), amount: (document.data()["amount"] as? String), discount: (document.data()["discount"] as? String)))
                                print("products loaded")
                            }
                            var storeName = document.data()["storeName"] as? String
                            storeName = storeName == "" ? "商店名稱" : storeName
                            var totalExpense = document.data()["totalExpense"] as? String
                            totalExpense = totalExpense == "" ? "尚未輸入" : totalExpense
                            self.receipts.append(Receipt(receiptID:document.documentID, storeName: storeName, receipt2Number: document.data()["receipt2Number"] as? String, receipt8Number: document.data()["receipt8Number"] as? String, year: document.data()["year"] as? String, month: document.data()["month"] as? String, day: document.data()["day"] as? String, totalExpense: totalExpense, products: self.products))
                                print("receipts loaded")
                            print(self.receipts)
                        }
                    }
                }
            }
        }
    }
    //實作讀取發票資料
    
    func getProducts(){

        for var receipt in receipts {
            self.ref.collection("Receipts").document(receipt.receiptID).collection("Products").addSnapshotListener { snapshot, error in
                if let error = error{
                    print(error.localizedDescription)
                }
                if let snapshot = snapshot{
                    for document in snapshot.documents{
                        receipt.products!.append(Product(productID: document.documentID, name: (document.data()["name"] as? String), count: (document.data()["count"] as? String), amount: (document.data()["amount"] as? String), discount: (document.data()["discount"] as? String)))
                        print("products loaded")
                    }
                    print(self.receipts)
                }
            }
        }
    }
    //實作讀取發票中商品內容
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReceiptDetailBySearch"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! ShowReceiptDetailViewController
                destinationController.receiptID = searchReceipts[indexPath.row].receiptID
            }
            // 跳轉到詳細發票頁面時，傳遞receiptID
        }
    }
}
extension ShowReceiptBySearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchReceipts.count
    }
    //設定cell數
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell", for: indexPath) as! ReceiptTableViewCell
        cell.storeNameLabel.text = searchReceipts[indexPath.row].storeName
        cell.receipt2NumberLabel.text = searchReceipts[indexPath.row].receipt2Number
        cell.receipt8NumberLabel.text = searchReceipts[indexPath.row].receipt8Number
        cell.totalExpenseLabel.text = searchReceipts[indexPath.row].totalExpense
        cell.dateLabel.text = "\(String(describing: searchReceipts[indexPath.row].month!))/\(String(describing:searchReceipts[indexPath.row].day!))"
        return cell
    }
    //設定cell內容
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)-> UISwipeActionsConfiguration? {
            
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            self.ref.collection("Receipts").document(self.receipts[indexPath.row].receiptID!).delete { error in
                if let error = error{
                    print(error.localizedDescription)
                   
                }else{
                    let alertController = UIAlertController(title: "成功", message: "發票刪除成功", preferredStyle: .alert)
                    let okActioin = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(okActioin)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    //實作往左滑刪除發票
}
extension ShowReceiptBySearchViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchReceipts = receipts.filter({ (Receipt) -> Bool in
            for product in Receipt.products!{
                return Receipt.storeName!.localizedCaseInsensitiveContains(searchText) || product.name!.localizedCaseInsensitiveContains(searchText)
            }
            return Receipt.storeName!.localizedCaseInsensitiveContains(searchText)
        })
        tableView.reloadData()
    }
    //實作利用商店名稱、商品名稱查詢發票
}
