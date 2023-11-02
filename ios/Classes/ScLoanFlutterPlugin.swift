//
//  ScLoan.swift
//  scgateway_flutter_plugin
//
//  Created by Ankit Deshmukh on 08/08/23.
//

import Foundation
import Flutter
import UIKit
import Loans

public class ScLoanFlutterPlugin: NSObject, FlutterPlugin {
    
    let currentViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
      
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "ScLoan_flutter_plugin", binaryMessenger: registrar.messenger())
      let instance = ScLoanFlutterPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let args = call.arguments as? Dictionary<String, Any> else { return }
        
        switch (call.method) {
            
        case "setup": do {
            guard let gateway = args["gateway"] as? String else {
                //SDK setup failure
                print("ScLoan setup failed: No gateway name provided")
                return
            }
            
            var env = SCLoanEnvironment.production
            
            if let hostEnv = args["env"] as? Int {
                env = SCLoanEnvironment(rawValue: hostEnv) ?? .production
            }
            
            ScLoan.instance.setup(
                config: ScLoanConfig(gatewayName: gateway, environment: env)) { success, error in
                    
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
                print("ScLoan apply failed: No interactionToken provided")
                return
            }
            
            ScLoan.instance.apply(
                presentingController: currentViewController,
                loanInfo: ScLoanInfo(interactionToken: interactionToken)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data ?? "success")
                    }
                }
        }
            
        case "pay": do {
            guard let interactionToken = args["interactionToken"] as? String else {
                //SDK setup failure
                print("ScLoan pay failed: No interactionToken provided")
                return
            }
            
            ScLoan.instance.pay(
                presentingController: currentViewController,
                loanInfo: ScLoanInfo(interactionToken: interactionToken)) { success, error in
                    
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
                print("ScLoan withdraw failed: No interactionToken provided")
                return
            }
            
            ScLoan.instance.withdraw(
                presentingController: currentViewController,
                loanInfo: ScLoanInfo(interactionToken: interactionToken)) { success, error in
                    
                    if let err = error {
                        result(self.convertErrorToJsonString(error: err))
                    } else {
                        result(success?.data)
                    }
                }
        }

        case "service": do {
            guard let interactionToken = args["interactionToken"] as? String else {
                //SDK setup failure
                print("ScLoan service failed: No interactionToken provided")
                return
            }
            
            ScLoan.instance.service(
                presentingController: currentViewController,
                loanInfo: ScLoanInfo(interactionToken: interactionToken)) { success, error in
                    
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
    
    private func convertErrorToJsonString(error: ScLoanError) -> String? {
        
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
