//
//  SignUpViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //連接storyboard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //收回鍵盤
    }
    
    func alertMessage(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okActioin)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signIn(){
        
        guard let email = emailTextField.text, email != "" , let name = nameTextField.text, name != "" , let password = passwordTextField.text , password != "" else {
            print("ERROR")
            alertMessage(title: "提醒", message: "請完整輸入註冊資料")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error{
                print(error.localizedDescription)
                self.alertMessage(title: "錯誤", message: "建立會員失敗")
            }
            if let authResult = authResult{
                print("\(String(describing: authResult.user.email)) 建立成功 ")
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
                //修改用者名稱
                let homePageVC = self.storyboard?.instantiateViewController(withIdentifier: "homePage")
                self.present(homePageVC!, animated: true, completion: nil)
                //跳轉至首頁
            }
        }
        //利用Firebase、FirebaseAuth實作註冊
        //39-63 用 guard 簡化 if巢狀層數
    }
    
    @IBAction func back(_ sender: Any){
        dismiss(animated: true)
    }

}
