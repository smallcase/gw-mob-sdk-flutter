//
//  SmallcaseListResponse.swift
//  clipboard_manager
//
//  Created by Ankit Deshmukh on 03/03/21.
//

import Foundation

struct Benchmark: Codable {
    var id: String
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case id, message
    }
}


struct SmallcaseProfileResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: Smallcase?
    
    enum CodingKeys: String, CodingKey {
        case success, errors, data
    }

}



struct SmallcaseListResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: SmallcaseData?
    
    struct SmallcaseData: Codable {
        
        var smallcases: [Smallcase]
        
        private enum CodingKeys: String, CodingKey {
            case smallcases
        }
        
    }
    
   
    
    enum CodingKeys: String, CodingKey {
        case success, errors, data
    }
    
}
