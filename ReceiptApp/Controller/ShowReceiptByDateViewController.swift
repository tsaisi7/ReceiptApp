//
//  ShowReceiptByDateViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class ShowReceiptByDateViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var totalExpLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    //連接storyboard
    
    var receipts: [Receipt] = []
    lazy var now = datePicker.date
    lazy var year = Calendar.current.component(.year, from: now)
    lazy var month = Calendar.current.component(.month, from: now)
    lazy var day = Calendar.current.component(.day, from: now)
    //取得現在年月日
    
    var totalExp = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.addTarget(self, action:  #selector(self.datePickerChanged), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        //設定各種delegate
        
        readData(year: year, month: month, day: day)
        //讀取特定日期發票資料
    }
    
    @objc func datePickerChanged(datePicke:UIDatePicker) {
        now = datePicker.date
        year = Calendar.current.component(.year, from: now)
        month = Calendar.current.component(.month, from: now)
        day = Calendar.current.component(.day, from: now)
        readData(year: year, month: month, day: day)
    }
    //偵測日期選擇器並更新日期讀取內容
    
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func readData(year:Int, month:Int, day:Int){
        var monthStr: String!
        var dayStr: String!
        if month < 10{
            monthStr = "0"+String(month)
        }else{
            monthStr = String(month)
        }
        if day < 10{
            dayStr = "0"+String(day)
        }else{
            dayStr = String(day)
        }
        self.ref.collection("Receipts").whereField("year", isEqualTo: String(year - 1911)).whereField("month", isEqualTo: monthStr!).whereField("day", isEqualTo: dayStr!).addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.receipts = []
                self.totalExp = 0
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.totalCountLabel.text = String(self.receipts.count)
                    self.totalExpLabel.text = String(self.totalExp)
                }
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
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.totalCountLabel.text = String(self.receipts.count)
                        self.totalExpLabel.text = String(self.totalExp)
                    }
                }
            }
        }
    }
    //實作讀取特定日期發票資料

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailByDate"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! ShowReceiptDetailViewController
                destinationController.receiptID = receipts[indexPath.row].receiptID
            }
            // 跳轉到詳細發票頁面時，傳遞receiptID
        }
    }
}
extension ShowReceiptByDateViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts.count
    }
    //設定cell數
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

