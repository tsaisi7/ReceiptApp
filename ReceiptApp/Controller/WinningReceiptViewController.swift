//
//  WinningReceiptViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/20.
//

import UIKit

class WinningReceiptViewController: UIViewController {
    
    @IBOutlet weak var yearTextField: YearTextField!
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var winningNumberTextField: Receipt8TextField!
    @IBOutlet weak var searchButton: UIButton!{
        didSet{
            searchButton.layer.cornerRadius = 5
        }
    }
    //連接storyboard
    
    let monthsArray = ["1月＆2月","3月＆4月","5月＆6月","7月＆8月","9月＆10月","11月＆12月"]
    var month = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        monthPickerView.delegate = self
        monthPickerView.dataSource = self
        //設定各種delegate
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    override func viewWillAppear(_ animated: Bool) {
        winningNumberTextField.text = ""
        //每次返回查詢中獎頁面時，清除中獎號碼
    }
    
    @IBAction func searchReceipt(){
        if let year = yearTextField.text ,let winningNumber = winningNumberTextField.text{
            if year != "" && winningNumber != ""{

                if let controller = storyboard?.instantiateViewController(withIdentifier: "showWinningReceipt") as? ShowWinningReceiptViewController{
                    controller.year = year
                    controller.receipt8Number = winningNumber
                    controller.month1 = month
                    controller.month2 = month + 1
                    navigationController?.pushViewController(controller, animated: true)
                }
                //跳轉到顯示中獎發票頁面
            }else {
                let alertController = UIAlertController(title: "提醒", message: "請輸入所有資料", preferredStyle: .alert)
                let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActioin)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    //實作中獎查詢
}
extension WinningReceiptViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return monthsArray.count
    }
    //設定選擇器內容個數
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return monthsArray[row]
    }
    //設定選擇器內容
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        month = row * 2 + 1
        print(month)
    }
    //設定選擇中的月份
}

