//
//  AnalyzeViewController.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/23.
//

import UIKit
import AAInfographics
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class AnalyzeViewController: UIViewController {

    @IBOutlet var chartView: UIView!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var lastButton: UIButton!
    
    //連接storyboard
    var now = Date()
    lazy var year = Calendar.current.component(.year, from: now)
    var datas: [[Any]]!
    var analyzeData : AnalyzeData!
    var aaChartView: AAChartView!
    var chartModel: AAChartModel!
    let group  = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.analyzeData = AnalyzeData()
        self.analyzeData.initialAllAnlyzeData()
        self.getDataWithYear(year: self.year)
        
        let chartViewWidth  = self.chartView.frame.size.width
        let chartViewHeight = self.chartView.frame.size.height
        self.aaChartView = AAChartView()
        self.aaChartView.frame = CGRect(x:0,y:0,width:chartViewWidth,height:chartViewHeight)
        self.chartView.addSubview(self.aaChartView)
        //設定圓餅圖位置

        self.group.notify(queue: DispatchQueue.main){
            self.chartModel = AAChartModel()
                .chartType(.pie)//圖表類型
                .dataLabelsEnabled(false)
                .tooltipValueSuffix("NTD")//浮動提示框單位後綴
                .colorsTheme(["#F4E500","#FDC60B","#F18E1C","#EA621F","#E32322","#E32322","#6D398B","#444E99","#2A71B0","#0696BB","#008E5B","#8CBB26"])
                .series([
                    AASeriesElement()
                        .name("消費金額")
                        .innerSize("50%")
                        .data(self.analyzeData.backAnlyzeDataArray())
                    ])
            self.aaChartView.aa_drawChartWithChartModel(self.chartModel)
        }
        //建立個月份消費圓餅圖
    }
    
    @IBAction func nextMonth(){
        self.year += 1
        self.yearLabel.text = String(year - 1911)
        self.getDataWithYear(year: self.year)
        self.group.notify(queue: DispatchQueue.main){
            self.chartModel = AAChartModel()
                .chartType(.pie)//圖表類型
                .dataLabelsEnabled(false)
                .tooltipValueSuffix("NTD")//浮動提示框單位後綴
                .colorsTheme(["#F4E500","#FDC60B","#F18E1C","#EA621F","#E32322","#E32322","#6D398B","#444E99","#2A71B0","#0696BB","#008E5B","#8CBB26"])
                .series([
                    AASeriesElement()
                        .name("消費金額")
                        .innerSize("50%")
                        .data(self.analyzeData.backAnlyzeDataArray())
                    ])
            self.aaChartView.aa_drawChartWithChartModel(self.chartModel)
        }
    }
    
    @IBAction func lastMonth(){
        self.year -= 1
        self.yearLabel.text = String(year - 1911)
        self.getDataWithYear(year: self.year)
        self.group.notify(queue: DispatchQueue.main){
            self.chartModel = AAChartModel()
                .chartType(.pie)//圖表類型
                .dataLabelsEnabled(false)
                .tooltipValueSuffix("NTD")//浮動提示框單位後綴
                .colorsTheme(["#F4E500","#FDC60B","#F18E1C","#EA621F","#E32322","#E32322","#6D398B","#444E99","#2A71B0","#0696BB","#008E5B","#8CBB26"])
                .series([
                    AASeriesElement()
                        .name("消費金額")
                        .innerSize("50%")
                        .data(self.analyzeData.backAnlyzeDataArray())
                    ])
            self.aaChartView.aa_drawChartWithChartModel(self.chartModel)
        }
    }
    
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func getDataWithYear(year: Int){
        for i in 1...12{
            let yearStr = String(year - 1911)
            let monthStr = i < 10 ? String(format:"%02d",i) : String(i)
            self.group.enter()
            self.ref.collection("Receipts").whereField("year", isEqualTo: yearStr).whereField("month", isEqualTo: monthStr).getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.group.leave()
                    return
                }
                if let snapshot = snapshot{
                    var totalExp: Int = 0
                    for document in snapshot.documents{
                        var totalExpense = document.data()["totalExpense"] as? String
                        totalExpense = totalExpense == "" ? "尚未輸入" : totalExpense
                        if totalExpense != "尚未輸入"{
                            totalExp += Int(totalExpense!)!
                        }
                    }
                    print(totalExp)
                    self.analyzeData.setAnlyzeData(month: i, expense: totalExp)
                    self.group.leave()
                }
            }
        }
    }
}
