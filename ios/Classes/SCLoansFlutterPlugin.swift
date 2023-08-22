//
//  SCLoans.swift
//  scgateway_flutter_plugin
//
//  Created by Ankit Deshmukh on 08/08/23.
//

import Foundation
import Flutter
import UIKit
import Loans

public class SCLoansFlutterPlugin: NSObject, FlutterPlugin {
    
    let currentViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
      
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "scloans_flutter_plugin", binaryMessenger: registrar.messenger())
      let instance = SwiftScgatewayFlutterPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let args = call.arguments as? Dictionary<String, Any> else { return }
        
        switch (call.method) {
            
        case "setup": do {
            guard let gateway = args["gateway"] as? String else {
                //SDK setup failure
                print("SCLoans setup failed: No gateway name provided")
                return
            }
            
            var env = SCLoanEnvironment.production
            
            if let hostEnv = args["env"] as? Int {
                env = SCLoanEnvironment(rawValue: hostEnv) ?? .production
            }
            
            SCLoans.instance.setup(
                config: SCLoanConfig(gatewayName: gateway, environment: env)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data)
                    }
                }
        }
            
        case "apply": do {
            guard let interactionToken = args["interactionToken"] as? String else {
                //SDK setup failure
                print("SCLoans apply failed: No interactionToken provided")
                return
            }
            
            SCLoans.instance.apply(
                presentingController: currentViewController,
                loanInfo: SCLoanInfo(interactionToken: interactionToken)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data)
                    }
                }
        }
            
        case "pay": do {
            guard let interactionToken = args["interactionToken"] as? String else {
                //SDK setup failure
                print("SCLoans pay failed: No interactionToken provided")
                return
            }
            
            SCLoans.instance.pay(
                presentingController: currentViewController,
                loanInfo: SCLoanInfo(interactionToken: interactionToken)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data)
                    }
                }
        }
            
        case "withdraw": do {
            guard let interactionToken = args["interactionToken"] as? String else {
                //SDK setup failure
                print("SCLoans withdraw failed: No interactionToken provided")
                return
            }
            
            SCLoans.instance.withdraw(
                presentingController: currentViewController,
                loanInfo: SCLoanInfo(interactionToken: interactionToken)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data)
                    }
                }
        }
            
        default:
            result("Flutter method not implemented on iOS")
        }
    }
    
    private func convertErrorToJsonString(error: SCLoanError) -> String? {
        
        var errorDict : [String: Any?] = [
            "isSuccess": error.isSuccess,
            "errorCode": error.errorCode,
            "errorMessage": error.errorMessage,
        ]
        
        if let errorData = error.data {
            errorDict["data"] = errorData.toDictionary
        }
        
        return errorDict.toJsonString
    }
    
}
