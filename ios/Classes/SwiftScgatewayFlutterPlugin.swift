import Flutter
import UIKit
import SCGateway

enum IntentType: String {
    case connect = "CONNECT"
    case transaction = "TRANSACTION"
    case holding = "HOLDINGS_IMPORT"
    case fetchFunds = "FETCH_FUNDS"
    case sipSetup = "SIP_SETUP"
    case authoriseHoldings = "AUTHORISE_HOLDINGS"
}

public class SwiftScgatewayFlutterPlugin: NSObject, FlutterPlugin {
    
  let currentViewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "scgateway_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftScgatewayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            
    if(call.method == "setFlutterSdkVersion") {
          if let args = call.arguments as? Dictionary<String, Any> {
              SCGateway.shared.setSDKType(type: "flutter")
              SCGateway.shared.setHybridSDKVersion(version: args["flutterSdkVersion"] as! String)
              result("success")
          }
      }
      
      else if(call.method == "getSdkVersion") {
          if let args = call.arguments as? Dictionary<String, Any> {
              let scgatewayFlutterPluginVersion = "ios:\(SCGateway.shared.getSdkVersion()),flutter:\(args["flutterSdkVersion"] as! String)"
              result(scgatewayFlutterPluginVersion)
          }
      }
      
    //MARK: Initialize Gateway SDK
     else if(call.method == "initializeGateway") {
        if let args = call.arguments as? Dictionary<String, Any>,
 
           let authToken = args["authToken"] as? String {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                print("Initializing gateway")
                
                SCGateway.shared.initializeGateway(sdkToken: authToken) { success, error in
                    
                    if !success {
                        print(error as Any)

                        if let error = error as? TransactionError {
                            result(
                                FlutterError.init(
                                    code: (
                                        self.getJsonStringResult(
                                            success: false,
                                            data: nil,
                                            errorCode: error.rawValue,
                                            errorMessage: error.message,
                                            transaction: "ERROR"
                                        )
                                    ),
                                    message: nil,
                                    details: nil
                                )
                            )
                        }
                        else {
                            result(
                                FlutterError.init(
                                    code: (
                                        self.getJsonStringResult(
                                            success: false,
                                            data: nil,
                                            errorCode: nil,
                                            errorMessage: error.debugDescription,
                                            transaction: "ERROR"
                                        )
                                    ),
                                    message: nil,
                                    details: nil
                                )
                            )
                        }
                        return
                    }
                    
                    print(success)
                }
                
                result(
                    self.getJsonStringResult(
                        success: true,
                        data: nil,
                        errorCode: nil,
                        errorMessage: nil,
                        transaction: nil
                    )
                )
            }
        }
        
    }
        
     //MARK: Set Config Environment
     else if (call.method == "setConfigEnvironment") {
         
        if let args = call.arguments as? Dictionary<String, Any>,
                   
                    let isLeprechaunActive = args["leprechaun"] as? Bool,
                    let gateway = args["gateway"] as? String,
                    let environment = args["env"] as? String,
                    let amoEnabled = args["amo"] as? Bool,
                    let brokerConfig = args["brokers"] as? [String] {
            
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        let config = GatewayConfig(gatewayName: gateway,
                                                   brokerConfig: brokerConfig ,
                                                   apiEnvironment: self.getApiEnv(index: environment),
                                                   isLeprechaunActive: isLeprechaunActive,
                                                   isAmoEnabled: amoEnabled)
                        
                        SCGateway.shared.setup(config: config) { (success, error) in
                            
                            if(success) {
                                //SDK setup successfull
                                print("SDK setup completed")
                                
                                result(
                                    self.getJsonStringResult(
                                        success: true,
                                        data: nil,
                                        errorCode: nil,
                                        errorMessage: nil,
                                        transaction: nil
                                    )
                                )
                                
                            } else {
                                //SDK setup failure
                                print("SDK setup failed: \(error.debugDescription)")
                                
                                result(
                                    self.getJsonStringResult(
                                        success: true,
                                        data: nil,
                                        errorCode: nil,
                                        errorMessage: error.debugDescription,
                                        transaction: nil
                                    )
                                )
                            }
                            
                        }
                    }
                }
        }
        
     //MARK: Trigger Transaction
    else if (call.method == "triggerTransaction") {
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let transactionId = args["transactionId"] as? String {
            
                    do {
                        
                        try SCGateway.shared.triggerTransactionFlow(transactionId: transactionId , presentingController: currentViewController) { [weak self]  gatewayResult in
                            
                            print(gatewayResult)
                            
                            switch gatewayResult {
                                
                            case .success(let response):
                                print("Transaction: RESPONSE: \(response)")
                                switch response {
                                
                                    // MARK:- CONNECT
                                    case let .connect(connectTxnResponse):

                                    let connectData = Data(connectTxnResponse.utf8)
                                    
                                    do {
                                        
                                        if let connectResponseJson = try JSONSerialization.jsonObject(with: connectData, options: []) as? [String: Any] {
                                            
                                            if let userAuthToken = connectResponseJson["smallcaseAuthToken"] as? String {
                                                print("Initialising SDK with authToken = \(userAuthToken)")
                                                
                                                //Initialise gateway if CONNECT was successfull
                                                SCGateway.shared.initializeGateway(sdkToken: (userAuthToken)) { success, error in
                                                    
                                                    print("SDK Initialised = \(success)")
                                                    
                                                    if !success {
                                                        
                                                        //Gateway initialisation failed
                                                        
                                                        print(error ?? "")
                                                        
                                                        if let error = error as? TransactionError {
                                                            
                                                            //Gateway initialisation failed with TransactionError
                                                            
                                                            result(
                                                                FlutterError.init(
                                                                    code: (
                                                                        self?.getJsonStringResult(
                                                                            success: false,
                                                                            data: nil,
                                                                            errorCode: error.rawValue,
                                                                            errorMessage: error.message,
                                                                            transaction: "ERROR"
                                                                        )
                                                                    )!,
                                                                    message: nil,
                                                                    details: nil
                                                                )
                                                            )
                                                            
                                                            return
                                                            
                                                        } else {
                                                            
                                                            //Gateway initialisation failed with generic error
                                                            
                                                            result(
                                                                FlutterError.init(
                                                                    code: (
                                                                        self?.getJsonStringResult(
                                                                            success: false,
                                                                            data: nil,
                                                                            errorCode: nil,
                                                                            errorMessage: error.debugDescription,
                                                                            transaction: "ERROR"
                                                                        )
                                                                    )!,
                                                                    message: nil,
                                                                    details: nil
                                                                )
                                                            )
                                                        }
                                                        return
                                                    }
                                                }

                                                result(
                                                    self?.getJsonStringResult(
                                                        success: true,
                                                        data: connectTxnResponse,
                                                        errorCode: nil,
                                                        errorMessage: nil,
                                                        transaction: "CONNECT"
                                                    )
                                                )
                                                
                                            } else {
                                                print("Failed to fetch smallcaseAuthToken from CONNECT response")
                                            }
                                        }
                                    } catch let error as NSError {
                                        print("Failed to convert CONNECT response to JSON: \(error.debugDescription)")
                                    }
                                    
                                    // MARK:- TRANSACTION
                                    case let .transaction(_, transactionData):

                                    do {
                                        let jsonEncoder = JSONEncoder()
                                        
                                        let jsonData = try jsonEncoder.encode(transactionData)
                                        
                                        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                        
                                        if let transactionSuccessData = jsonObject as? [String: Any] {
                                            
                                            var response: [String: Any] = [:]
                                            
                                            response["success"] = true
                                            response["data"] = transactionSuccessData
                                            response["transaction"] = "TRANSACTION"
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
                                            let jsonString = String(data: jsonData, encoding: .utf8)
                                            
                                            result(jsonString)
                                            
                                            return
                                        }
                                        
                                    } catch {
                                    
                                    }
                                
                                    // MARK:- HOLDINGS_IMPORT
                                    case .holdingsImport(let smallcaseAuthToken, let broker, _, _):

                                        var holdingsResponse : [String: Any] = [:]
                                        
                                        holdingsResponse["smallcaseAuthToken"] = smallcaseAuthToken
                                        holdingsResponse["broker"] = broker
                                        
                                        let jsonData = try! JSONSerialization.data(withJSONObject: holdingsResponse, options: [])
                                        let holdingsResponseJsonString = String(data: jsonData, encoding: .utf8)
                                        
                                        result(
                                            self?.getJsonStringResult(
                                                success: true,
                                                data: holdingsResponseJsonString,
                                                errorCode: nil,
                                                errorMessage: nil,
                                                transaction: "HOLDINGS_IMPORT"
                                            )
                                        )
                                        
                                    return
                                    
                                    // MARK:- SIP_SETUP
                                    case .sipSetup(let smallcaseAuthToken, let sipDetails, _):

                                    do{
                                        let jsonEncoder = JSONEncoder()
                                        let jsonData = try jsonEncoder.encode(sipDetails)
                                        
                                        let data = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                        
                                        if let sipResponse = data as? [String: Any] {
                                            
                                            print("SIP_SETUP response: \(sipResponse)")
                                            
                                            var resDict: [String: Any] = [:]
                                            
                                            resDict["success"] = true
                                            resDict["data"] = sipResponse
                                            resDict["smallcaseAuthToken"] = smallcaseAuthToken
                                            resDict["transaction"] = "SIP_SETUP"
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: resDict, options: [])
                                            let jsonString = String(data: jsonData, encoding: .utf8)
                                            
                                            result(jsonString)
                                            
                                            return
                                        }
                                        
                                    } catch {
                                        //TODO: catch json exception
                                    }
                                    
                                default:
                                    return
                                }
                            
                                
                            //MARK:- Transaction Error
                            case .failure(let error):
                                
                                print("TRANSACTION ERROR :\(error)")
                                
                                result(
                                    FlutterError.init(
                                        code: (
                                            self?.getJsonStringResult(
                                                success: false,
                                                data: nil,
                                                errorCode: error.rawValue,
                                                errorMessage: error.message,
                                                transaction: "ERROR"
                                            )
                                        )!,
                                        message: nil,
                                        details: nil
                                    )
                                )
                                
                                return
                            }
                        }
                    }
                    catch SCGatewayError.uninitialized {
                        print(SCGatewayError.uninitialized.message)
                    }
                    catch let err {
                        print(err)
                    }
            }
    }
        
    //MARK: Lead Gen
    else if(call.method == "leadGen") {
        
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let name = args["name"] as? String,
            let email = args["email"] as? String,
            let contact = args["contact"] as? String {
            
             var params:[String:String] = [:]
                   params["name"] = name
                   params["email"] = email
                   params["contact"] = contact
            SCGateway.shared.triggerLeadGen(presentingController: currentViewController, params: params)
        } else {
            result(FlutterError.init(code: "bad args", message: "error at method leadGen", details: nil))
        }
    }
    
    //MARK: Lead Gen with Status
    else if(call.method == "leadGenWithStatus") {
        
        if let args = call.arguments as? Dictionary<String, Any>,
           
           let name = args["name"] as? String,
           let email = args["email"] as? String,
           let contact = args["contact"] as? String {
            
            var params:[String:String] = [:]
            params["name"] = name
            params["email"] = email
            params["contact"] = contact
            SCGateway.shared.triggerLeadGen(presentingController: currentViewController, params: params) { leadStatus in
                result(leadStatus)
            }
        } else {
            result(FlutterError.init(code: "bad args", message: "error at method leadGenWithStatus", details: nil))
        }
        
    }
        
    //MARK: Get All Smallcases
    else if(call.method == "getAllSmallcases") {
        
        SCGateway.shared.getSmallcases(params: nil) { (data, error) in
            
            guard let response = data else {
                
                print(error ?? "No error object")
                return
                
            }
         
            let smallcasesJson = try! JSONSerialization.jsonObject(with: response, options: [])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
            
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            result(jsonString)
            
            return
        }
        
     }
        
    //MARK: Get User Investments
    else if(call.method == "getUserInvestments") {
            
        SCGateway.shared.getUserInvestments(iscids: nil) { (data, error) in
            
            guard let response = data else {
                
                print(error ?? "No error object")
                return
                
            }
            
            let smallcasesJson = try! JSONSerialization.jsonObject(with: response, options: [])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
            
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            result(jsonString)
            
            return
        }
        
    }
     
    //MARK: Get Exited Smallcases
     else if(call.method == "getExitedSmallcases") {
        
        SCGateway.shared.getExitedSmallcases{ (data, error) in
            
            guard let response = data else {
                print(error ?? "No error object")
                return
            }
                       
           let smallcasesJson = try! JSONSerialization.jsonObject(with: response, options: [])
                       
           let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
                       
           let jsonString = String(data: jsonData, encoding: .utf8)
                       
           result(jsonString)
           
           return
        }
        
     }
      
     //MARK: Mark smallcase archive
     else if(call.method == "markArchive") {
        
        if let args = call.arguments as? Dictionary<String, Any>,
            
            let iscid = args["iscid"] as? String {
                
            
            SCGateway.shared.markSmallcaseArchive(iscid: iscid) { (data, error) in
                
                guard let response = data else {
                    
                    print(error ?? "No error object")
                                   
                    return
                }
                               
               let smallcasesJson = try! JSONSerialization.jsonObject(with: response, options: [])
                               
               let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
                               
               let jsonString = String(data: jsonData, encoding: .utf8)
                               
               result(jsonString)
                
                return
            }
                
        } else {
                result(FlutterError.init(code: "bad args", message: "error at method markArchive", details: nil))
            }
        }
        
     //MARK: Logout User
     else if(call.method == "logoutUser") {
        
        SCGateway.shared.logoutUser(presentingController: currentViewController) { success, error in
            
            if(success) {
                result("Logout successful")
            } else {
                result(FlutterError.init(code: "bad args", message: "error at method logout user", details: nil))
            }
            
        }
        
     }
     
     //MARK: Launch smallplug
     else if(call.method == "launchSmallplug") {
        
        if let args = call.arguments as? Dictionary<String, Any> {
            let target = args["targetEndpoint"] as? String
            let params = args["params"] as? String
                
            SCGateway.shared.launchSmallPlug(presentingController: currentViewController, smallplugData: SmallplugData(target, params), completion: {
                response, error in
                
                if let smallplugResponse = response {
                    
                    result(self.getJsonStringResult(success: true, data: smallplugResponse as? String, errorCode: nil, errorMessage: nil, transaction: nil))
                    
                }
            })
            
        } else {
            
            SCGateway.shared.launchSmallPlug(presentingController: currentViewController, smallplugData: nil, completion: {
                response, error in
                
                if let smallplugResponse = response {
                    
                    result(self.getJsonStringResult(success: true, data: smallplugResponse as? String, errorCode: nil, errorMessage: nil, transaction: nil))
                    
                }
            })
            
        }
     }
      
      //MARK: Show orders
      else if (call.method == "showOrders") {
          
          SCGateway.shared.showOrders(presentingController: currentViewController) { success, error in
              
              if success {
                  result(self.getJsonStringResult(success: true, data: nil, errorCode: nil, errorMessage: nil, transaction: nil))
              } else {
                  
                  if let showOrdersError = error as? ObjcTransactionError {
                      result(
                        self.getJsonStringResult(
                            success: false,
                            data: nil,
                            errorCode: showOrdersError.code,
                            errorMessage: showOrdersError.domain,
                            transaction: nil
                        )
                      )
//                      self.showPopup(title: "Error", msg: "\(errorPopupString.domain) \(errorPopupString.code)")
                  }
                  
              }
          }
      }
     
    else {
            result("Flutter method not implemented on iOS")
        }
    }
    
    func getJsonStringResult(success: Bool, data: String?, errorCode: Int?, errorMessage: String?, transaction: String?) -> String {
        
        let res:NSMutableDictionary = NSMutableDictionary()
        
        res.setValue(success, forKey: "success")
        res.setValue(data, forKey: "data")
        res.setValue(transaction, forKey: "transaction")
        res.setValue(errorCode, forKey: "errorCode")
        res.setValue(errorMessage, forKey: "error")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: res, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return jsonString!
    }
    
    func getApiEnv(index: String) -> Environment {
        
        switch index {
        case "GatewayEnvironment.PRODUCTION":
            return .production
        case "GatewayEnvironment.DEVELOPMENT":
            return .development
        case "GatewayEnvironment.STAGING":
            return .staging
        default:
            return .production
        }
    }
        
}

