//
//  Receipt.swift
//  ReceiptApp
//
//  Created by CAI SI LIOU on 2021/12/15.
//

import Foundation

struct Receipt {
    var receiptID: String!
    var storeName: String?
    var receipt2Number: String!
    var receipt8Number: String!
    var year: String!
    var month: String!
    var day: String!
    var totalExpense: String?
    var products: [Product]?
}
