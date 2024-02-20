//
//  ScLoan.swift
//  loans
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
                        result(self.convertErrorToFlutterError(error: err))
                    } else {
                        result(self.convertSuccessToJsonString(success: success))
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
                        result(self.convertErrorToFlutterError(error: err))
                    } else {
                        result(self.convertSuccessToJsonString(success: success))
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
                        result(self.convertErrorToFlutterError(error: err))
                    } else {
                        result(self.convertSuccessToJsonString(success: success))
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
                        result(self.convertErrorToFlutterError(error: err))
                    } else {
                        result(self.convertSuccessToJsonString(success: success))
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
                        result(self.convertErrorToFlutterError(error: err))
                    } else {
                        result(self.convertSuccessToJsonString(success: success))
                    }
                }
        }
            
        default:
            result("Flutter method not implemented on iOS")
        }
    }
    
    // This conversion is vital because only by passing a FlutterError object to the result:FlutterResult call will the error be thrown in the catch block on the dart side
    private func convertErrorToFlutterError(error: ScLoanError) -> FlutterError {
        
        var errorDict : [String: Any?] = [
            "isSuccess": error.isSuccess,
            "code": error.errorCode,
            "message": error.errorMessage,
        ]
        
        if let errorData = error.data {
            errorDict["data"] = errorData
        }
        
        var flutterError = FlutterError(code: String(error.errorCode), message: error.errorMessage, details: errorDict.toJsonString)
        
        
        return flutterError
    }
    
    private func convertSuccessToJsonString(success: ScLoanSuccess?) -> String? {
        
        guard let res = success else { return nil }
        
        var successDict : [String: Any?] = [
            "isSuccess": res.isSuccess,
        ]
        
        if let data = res.data {
            successDict["data"] = data
        }
        
        return successDict.toJsonString
    }
    
}
