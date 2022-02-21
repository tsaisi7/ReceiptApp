//
//  AnalyzeData.swift
//  ReceiptApp
//
//  Created by Adam Liu on 2022/2/21.
//

import Foundation

class AnalyzeData: NSObject {
    
    private var Datas = [Int: Int]()

    func initialAllAnlyzeData(){
        for i in 1 ... 12 {
            self.Datas[i] = 0
        }
        print(self.Datas)
    }
    
    func setAnlyzeData(month: Int, expense: Int){
        self.Datas[month] = expense
    }
    
    func backAnlyzeDataArray() -> Array<Any>{
        var arrays: [Any] = []
        for i in 1 ... 12{
            let array = [String(format:"%02d月",i), self.Datas[i] as Any] as [Any]
            arrays.append(array)
        }
        print(arrays)
        return arrays
    }
    
}
