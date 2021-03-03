//
//  Constituent.swift
//  clipboard_manager
//
//  Created by Ankit Deshmukh on 03/03/21.
//

import Foundation


struct Constituent: Codable {
    var shares: Double?
    var stockName: String
    var ticker: String
    var weight: Double?
    var returns: Double?
    var averagePrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case shares, stockName, ticker, weight, returns, averagePrice
    }
}
