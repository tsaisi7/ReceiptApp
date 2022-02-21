//
//  ShowReceiptViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/17.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class ShowReceiptViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var totalExpLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    //連接storyboard
    
    var receipts: [Receipt] = []
    var totalExp = 0

    //建立個月份的總花費
    var now = Date()
    lazy var year = Calendar.current.component(.year, from: now)
    lazy var month = Calendar.current.component(.month, from: now)
    lazy var day = Calendar.current.component(.day, from: now)
    //取得現在年、月、日
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //設定delegate
        
        readData(year: year, month: month, day: nil)
        //讀取特定年月份Firestore的資料
        
    }
    
    @IBAction func nextMonth(){
        if month != 12 {
            month = month + 1
            readData(year: year, month: month, day: nil)

        }else{
            year = year + 1
            month = 1
            readData(year: year, month: month, day: nil)

        }
    }
    //實作下個月份，改變tableView的資料
    
    @IBAction func lastMonth(){
        if month != 1 {
            month = month - 1
            readData(year: year, month: month, day: nil)

        }else{
            year = year - 1
            month = 12
            readData(year: year, month: month, day: nil)

        }
    }
    //實作上個月份，改變tableView的資料
    
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func refresh(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.totalCountLabel.text = String(self.receipts.count)
            self.totalExpLabel.text = String(self.totalExp)
        }
    }
    
    func readData(year:Int, month:Int, day:Int?){
        
        var monthStr: String
        monthStr = month < 10 ? String(format:"%02d",month) : String(month)
        
        self.ref.collection("Receipts").whereField("year", isEqualTo: String(year - 1911)).whereField("month", isEqualTo: monthStr).addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.receipts = []
                self.totalExp = 0
                self.dateLabel.text = "民國\(year - 1911)年\(month)月"
                self.refresh()
                for document in snapshot.documents{
                    var storeName = document.data()["storeName"] as? String
                    storeName = storeName == "" ? "商店名稱" : storeName
                    var totalExpense = document.data()["totalExpense"] as? String
                    totalExpense = totalExpense == "" ? "尚未輸入" : totalExpense
                    self.receipts.append(Receipt(receiptID:document.documentID, storeName: storeName, receipt2Number: document.data()["receipt2Number"] as? String, receipt8Number: document.data()["receipt8Number"] as? String, year: document.data()["year"] as? String, month: document.data()["month"] as? String, day: document.data()["day"] as? String, totalExpense: totalExpense))
                        print("receipts loaded")
                        print("---\(self.receipts)")
                    if totalExpense != "尚未輸入"{
                        self.totalExp += Int(totalExpense!)!
                    }
                    self.refresh()
                }
            }
        }
        
    }
    //實作讀取指定年月份的資料
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! ShowReceiptDetailViewController
                destinationController.receiptID = receipts[indexPath.row].receiptID
            }
        }
        // 跳轉到詳細發票頁面時，傳遞receiptID
    }
}
extension ShowReceiptViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts.count
    }
    //設定cell數量
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell") as! ReceiptTableViewCell
//        if cell == nil{
//            cell = ReceiptTableViewCell(style: .default, reuseIdentifier: "receiptCell")
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell", for: indexPath) as! ReceiptTableViewCell
        cell.storeNameLabel.text = receipts[indexPath.row].storeName
        cell.receipt2NumberLabel.text = receipts[indexPath.row].receipt2Number
        cell.receipt8NumberLabel.text = receipts[indexPath.row].receipt8Number
        cell.totalExpenseLabel.text = receipts[indexPath.row].totalExpense
        cell.dateLabel.text = "\(String(describing: receipts[indexPath.row].month!))/\(String(describing:receipts[indexPath.row].day!))"
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
