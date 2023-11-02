//
//  String+Ext.swift
//  Mixpanel-swift
//
//  Created by Ankit Deshmukh on 08/08/23.
//

import Foundation

extension String {
    public func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    public var toDictionary : [String : Any]? {
        
        let data = Data(self.utf8)
        
        do {
            
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                return jsonDictionary
            }
            
        } catch let error as NSError {
            print("Failed to convert JSON string to dictionary: \(error.localizedDescription)")
        }
        
        return nil
    }
}
