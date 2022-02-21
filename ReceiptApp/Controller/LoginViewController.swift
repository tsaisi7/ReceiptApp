//
//  LoginViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    // 連接storyboard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // 收回鍵盤
    }
    
    func alertMessage(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okActioin)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func login(){

        guard let email = emailTextField.text, email != "" , let password = passwordTextField.text , password != ""  else {
            print("ERROR")
            alertMessage(title: "提醒", message: "請完整輸入登入資料")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error{
                print(error.localizedDescription)
                self.alertMessage(title: "提醒", message: "帳號或密碼錯誤")
            }
            if let authResult = authResult{
                print("\(String(describing: authResult.user.email)) 登入成功 ")
                let homePageVC = self.storyboard?.instantiateViewController(withIdentifier: "homePage")
                self.present(homePageVC!, animated: true, completion: nil)
            }
        }
        //利用Firebase、FirebaseAuth實作登入
        //38-53 用 guard 簡化 if巢狀層數
    }

}
