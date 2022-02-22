//
//  ScannerViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation
import FirebaseFirestore

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    //連接storyboard
    
    var captureSesion:AVCaptureSession?
    var previewLayer:AVCaptureVideoPreviewLayer!
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    var IDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.collection("Receipts").addSnapshotListener { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot{
                for document in snapshot.documents{
                    self.IDs.append(document.documentID)
                }
            }
        }
        //取得Firestore中Receipts的所有ID，之後判斷發票是否已儲存
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setScanner()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(captureSesion?.isRunning == false){
            captureSesion?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(captureSesion?.isRunning == true){
            captureSesion?.stopRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(captureSesion?.isRunning == true){
            captureSesion?.stopRunning()
        }
    }
    
    func alertMessage(title: String,message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okActioin)
        present(alertController, animated: true, completion: nil)
    }
    //實作各種彈出通知
    
    func setScanner(){
        captureSesion = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        let deviceInput: AVCaptureDeviceInput
        do{
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        }catch let error{
            print(error.localizedDescription)
            return
        }
        if (captureSesion?.canAddInput(deviceInput) ?? false){
            captureSesion?.addInput(deviceInput)
        }else{
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        if (captureSesion?.canAddOutput(metaDataOutput) ?? false){
            captureSesion?.addOutput(metaDataOutput)
            //關鍵！執行處理QRCode
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //metadataOutput.metadataObjectTypes表示要處理哪些類型的資料，處理QRCODE
            metaDataOutput.metadataObjectTypes = [.qr, .ean8 , .ean13 , .pdf417]
        }else{
                return
        }
        
        //用AVCaptureVideoPreviewLayer來呈現Session上的資料
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion!)
        //顯示size
        previewLayer.videoGravity = .resizeAspectFill
        //呈現在camView上面
        previewLayer.frame = scannerView.layer.frame
        //加入畫面
        view.layer.addSublayer(previewLayer)
        
        //顯示scan Area window 框框
        let size = 150
        let sWidth = Int(view.frame.size.width)
        let xPos = (sWidth/2)-(size/2)
        let scanRect = CGRect(x: CGFloat(xPos), y: 300 , width: CGFloat(size) , height: CGFloat(size))
        //設定scan Area window 框框
        let scanAreaView = UIView()
        scanAreaView.layer.borderColor = UIColor.yellow.cgColor
        scanAreaView.layer.borderWidth = 2
        scanAreaView.frame = scanRect
        view.addSubview(scanAreaView)
        view.bringSubviewToFront(scanAreaView)
                
        //開始影像擷取呈現鏡頭的畫面
        captureSesion?.startRunning()
    }
    //實作掃描
    
}
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSesion?.startRunning()
        if let metadataObject = metadataObjects.first{
            
            //AVMetadataMachineReadableCodeObject是從OutPut擷取到barcode內容
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {return}
            //將讀取到的內容轉成string
            guard let stringValue = readableObject.stringValue else {return}
            //掃到QRCode後的震動提示
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("-----QRcode: \(stringValue)")
            do {
                let regex = try NSRegularExpression(pattern: "[A-Z][A-Z][0-9]{19}[a-fA-F0-9]{16}", options: [])
                if regex.firstMatch(in: stringValue, options: [], range: NSRange(location: 0, length: stringValue.count)) == nil {
                    self.alertMessage(title: "抱歉", message: "無法辨識")
                    return
                }
            } catch let e as NSError{
                print(e.localizedDescription)
            }
            // 用RegularExpression 做驗證是否為發票的QRCode
            
            let alertController = UIAlertController(title: "掃描成功", message: "發票號碼：\((stringValue as NSString).substring(with: NSMakeRange(0, 2)))-\((stringValue as NSString).substring(with: NSMakeRange(2, 8)))", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "直接儲存", style: .default) { UIAlertAction in
                let receiptID = (stringValue as NSString).substring(with: NSMakeRange(0, 2)) + "-" + (stringValue as NSString).substring(with: NSMakeRange(2, 8))
                let receiptData = ["receiptID": receiptID,"storeName": "", "receipt2Number": (stringValue as NSString).substring(with: NSMakeRange(0, 2)), "receipt8Number": (stringValue as NSString).substring(with: NSMakeRange(2, 8)), "year": (stringValue as NSString).substring(with: NSMakeRange(10, 3)), "month": (stringValue as NSString).substring(with: NSMakeRange(13, 2)), "day": (stringValue as NSString).substring(with: NSMakeRange(15, 2)), "totalExpense": String(Int((stringValue as NSString).substring(with: NSMakeRange(29, 8)),radix: 16)!)] as [String: Any]
                for ID in self.IDs{
                    if ID == receiptID{
                        self.alertMessage(title: "提醒", message: "發票已儲存過了")
                        return
                    }
                }
                self.ref.collection("Receipts").document(receiptID).setData(receiptData){ (error) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }else{
                        self.alertMessage(title: "成功", message: "發票已上傳成功")
                    }
                }
            }
            let editAction = UIAlertAction(title: "編輯內容", style: .default) { UIAlertAction in
                if let addReceiptViewController = self.storyboard?.instantiateViewController(withIdentifier: "addReceiptVC") as? AddReceiptViewController{
                    addReceiptViewController.receipt2 = (stringValue as NSString).substring(with: NSMakeRange(0, 2))
                    addReceiptViewController.receipt8 = (stringValue as NSString).substring(with: NSMakeRange(2, 8))
                    addReceiptViewController.totalExp = String(Int((stringValue as NSString).substring(with: NSMakeRange(29, 8)),radix: 16)!)
                    addReceiptViewController.receiptYear = (stringValue as NSString).substring(with: NSMakeRange(10, 3))
                    addReceiptViewController.receiptMonth = (stringValue as NSString).substring(with: NSMakeRange(13, 2))
                    addReceiptViewController.receiptDay = (stringValue as NSString).substring(with: NSMakeRange(15, 2))
                    
                    self.navigationController?.pushViewController(addReceiptViewController, animated: true)
                }
            }
            alertController.addAction(saveAction)
            alertController.addAction(editAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}



