//
//  ProfileViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //連接storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = Auth.auth().currentUser?.email
        nameTextField.text = Auth.auth().currentUser?.displayName
        //預設使用者帳號、名稱
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // 收回鍵盤
    }
    
    @IBAction func changeProfile(){
        if emailTextField.text != "" && nameTextField.text != "" {
            if let email = emailTextField.text{
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }//更新帳號
            if let name = nameTextField.text{
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.commitChanges { error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }//更新名稱
            if let password = passwordTextField.text{
                Auth.auth().currentUser?.updatePassword(to: password) { error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }//更新密碼
        }
        //更新個人資料
    }
    @IBAction func logOut(){
        do {
             try Auth.auth().signOut()
             let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC")
             let delegate: SceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
             delegate.window?.rootViewController = loginVC
            //登出並將rootVC 設為登入畫面
             
         } catch let signoutError as NSError{
             print(signoutError)
         }
        //實作登出
    }
}
