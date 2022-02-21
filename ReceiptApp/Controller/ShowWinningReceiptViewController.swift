//
//  ShowWinningReceiptViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class ShowWinningReceiptViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var month1Label: UILabel!
    @IBOutlet weak var month2Label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //連接storyboard
    
    var year: String!
    var month1: Int!
    var month2: Int!
    var receipt8Number: String!
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    var receipts: [Receipt] = []
    var winningReceipts: [Receipt] = []
    var winningMoneys:[String] = []
    var isWin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yearLabel.text = year
        month1Label.text = String(month1)
        month2Label.text = String(month2)
        //預設輸入格內容
        
        readData()
        //讀取篩選過的發票
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    func readData(){
        var month1Str:String!
        var month2Str:String!
        
        month1Str = month1 < 10 ? "0"+String(month1) : String(month1)
        month2Str = month2 < 10 ? "0"+String(month2) : String(month2)
        
        self.ref.collection("Receipts").whereField("year", isEqualTo: "110").whereField("month", in: [month1Str!, month2Str!]).getDocuments { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.receipts = []
                for document in snapshot.documents{
                    var storeName = document.data()["storeName"] as? String
                    storeName = storeName == "" ? "商店名稱" : storeName
                    var totalExpense = document.data()["totalExpense"] as? String
                    totalExpense = totalExpense == "" ? "尚未輸入金額" : totalExpense
                    self.receipts.append(Receipt(receiptID:document.documentID, storeName: storeName, receipt2Number: document.data()["receipt2Number"] as? String, receipt8Number: document.data()["receipt8Number"] as? String, year: document.data()["year"] as? String, month: document.data()["month"] as? String, day: document.data()["day"] as? String, totalExpense: totalExpense))
                        print("receipts loaded")
                        print("---\(self.receipts)")
                }
                self.check()
                print("-------\(self.winningReceipts)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.isWin == true{
                        let alertController = UIAlertController(title: "恭喜", message: "你中獎了", preferredStyle: .alert)
                        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okActioin)
                        self.present(alertController, animated: true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: "好可惜", message: "你沒中獎了", preferredStyle: .alert)
                        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okActioin)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    //實作讀取發票
    
    func win(receipt: Receipt, money: String){
        self.winningReceipts.append(receipt)
        self.winningMoneys.append(money)
        isWin = true
    }
    
    func check(){
        let winningNumbers = Array(self.receipt8Number)
        for receipt in self.receipts{
            let numbers = Array(receipt.receipt8Number)
            switch winningNumbers {
                case let winning8 where winning8[0...7] == numbers[0...7]:
                win(receipt: receipt, money: "200,000")
                
                case let winning7 where winning7[1...7] == numbers[1...7]:
                win(receipt: receipt, money: "40,000")

                case let winning6 where winning6[2...7] == numbers[2...7]:
                win(receipt: receipt, money: "10,000")

                case let winning5 where winning5[3...7] == numbers[3...7]:
                win(receipt: receipt, money: "4,000")

                case let winning4 where winning4[4...7] == numbers[4...7]:
                win(receipt: receipt, money: "1,000")

                case let winning3 where winning3[5...7] == numbers[5...7]:
                win(receipt: receipt, money: "400")

                default: break
            }
        }
    }
    //實作對獎
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWinningReceiptDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! WinningReceiptDetailViewController
                destinationController.receipt = self.winningReceipts[indexPath.row]
                destinationController.winningMoney = self.winningMoneys[indexPath.row]
            }
            // 跳轉到中獎發票詳細頁面，傳遞發票、中獎金額
        }
    }
}
extension ShowWinningReceiptViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return winningReceipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "winningReceiptCell") as! WinningReceiptTableViewCell
        if cell == nil{
            cell = WinningReceiptTableViewCell(style: .default, reuseIdentifier: "winningReceiptCell")
        }
        cell.receipt8Label.text = winningReceipts[indexPath.row].receipt8Number
        cell.receipt2Label.text = winningReceipts[indexPath.row].receipt2Number
        cell.storeNameLabel.text = winningReceipts[indexPath.row].storeName
        cell.dateLabel.text = "\(String(describing: winningReceipts[indexPath.row].month!))/\(String(describing: winningReceipts[indexPath.row].day!))"
        cell.winningMoneyLabel.text = winningMoneys[indexPath.row]
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "winningReceiptCell", for: indexPath) as! WinningReceiptTableViewCell
//        cell.receipt8Label.text = winningReceipts[indexPath.row].receipt8Number
//        cell.receipt2Label.text = winningReceipts[indexPath.row].receipt2Number
//        cell.storeNameLabel.text = winningReceipts[indexPath.row].storeName
//        cell.dateLabel.text = "\(String(describing: winningReceipts[indexPath.row].month!))/\(String(describing: winningReceipts[indexPath.row].day!))"
//        cell.winningMoneyLabel.text = winningMoneys[indexPath.row]
        return cell
    }
    
    
}
