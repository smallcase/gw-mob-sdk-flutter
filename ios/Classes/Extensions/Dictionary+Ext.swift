//
//  Dictionary+Ext.swift
//  Mixpanel-swift
//
//  Created by Ankit Deshmukh on 08/08/23.
//

import Foundation

extension Dictionary {
    public var toJsonString : String? {
        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonObject, encoding: String.Encoding.utf8)
        } catch let dictionaryError as NSError {
            print("Unable to convert dictionary to json String :\(dictionaryError)")
            return nil
        }
    }
    
}
