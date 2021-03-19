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
     if(call.method == "initializeGateway") {
        if let args = call.arguments as? Dictionary<String, Any>,
 
           let authToken = args["authToken"] as? String {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                print("Initialize gateway")
                
                SCGateway.shared.initializeGateway(sdkToken: authToken) { data, error in
                    
                    if !data {
                        print(error as Any)
                    
                        
                        if let error = error as? TransactionError {
                            
//                            result(FlutterError.init(code: "Error", message: error.message, details: nil))
                            result(FlutterError.init(code: (self.getJsonStringResult(success: false, data: nil, errorCode: error.rawValue, errorMessage: error.message, transaction: "ERROR")), message: nil, details: nil))
                        }
                        else {
//                            result(FlutterError.init(code: "Error", message: error.debugDescription, details: nil))
                            result(FlutterError.init(code: (self.getJsonStringResult(success: false, data: nil, errorCode: nil, errorMessage: error.debugDescription, transaction: "ERROR")), message: nil, details: nil))
                        }
                        return
                    }
                    print(data)
                }
                
                result(self.getJsonStringResult(success: true, data: nil, errorCode: nil, errorMessage: nil, transaction: nil))
            }
        }
        
    }
        
     else if (call.method == "setConfigEnvironment") {
        if let args = call.arguments as? Dictionary<String, Any>,
                   
                   let isLeprechaunActive = args["leprechaun"] as? Bool,
                   let gateway = args["gateway"] as? String,
                    let environment = args["env"] as? String {
            
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let brokerConfig: [String]? = []

                        let config = GatewayConfig(gatewayName: gateway,
                                                          brokerConfig: brokerConfig ,
                                                          apiEnvironment: self.getApiEnv(index: environment),
                                                          isLeprechaunActive: isLeprechaunActive,
                                                          isAmoEnabled: true)
                        
                        SCGateway.shared.setup(config: config)
                        
                        result(self.getJsonStringResult(success: true, data: nil, errorCode: nil, errorMessage: nil, transaction: nil))
                }
        }
     }
        
    else if (call.method == "triggerTransaction") {
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let transactionId = args["transactionId"] as? String {
            
                    do {
                        
                        try SCGateway.shared.triggerTransactionFlow(transactionId: transactionId , presentingController: currentViewController) { [weak self]  gatewayResult in
                            switch gatewayResult {
                            case .success(let response):
                                print("Transaction: RESPONSE: \(response)")
                                switch response {
                                case let .connect(authToken, _):

                                    SCGateway.shared.initializeGateway(sdkToken: (authToken)) { data, error in

                                        if !data {
                                                print(error)
                                                    if let error = error as? TransactionError {
                                                        result(FlutterError.init(code: (self?.getJsonStringResult(success: false, data: nil, errorCode: error.rawValue, errorMessage: error.message, transaction: "ERROR"))!, message: nil, details: nil))
                                                    } else {
//                                                        result(FlutterError.init(code: "Error", message: error.debugDescription, details: nil))
                                                        result(FlutterError.init(code: (self?.getJsonStringResult(success: false, data: nil, errorCode: nil, errorMessage: error.debugDescription, transaction: "ERROR"))!, message: nil, details: nil))
                                                        }
                                                    return
                                            }
                                        print(data)
                                    }
                                
//                                result(authToken)
                                result(self?.getJsonStringResult(success: true, data: "\(authToken)", errorCode: nil, errorMessage: nil, transaction: "CONNECT"))
                                    
                                case let .transaction(authToken, transactionData):
                                    
                                    var transData: [String: Any]
                                    do {
                                        let jsonEncoder = JSONEncoder()
                                        
                                        let jsonData = try jsonEncoder.encode(transactionData)
                                        
                                        let data = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                        
                                        if let dictionary = data as? [String: Any] {
//                                            transData = dictionary["data"]! as? String
                                            transData = dictionary as! [String : Any]

                                            
                                            print(transData)
                                            
                                            var resDict: [String: Any] = [:]
                                            
                                            resDict["success"] = true
                                            resDict["data"] = transData
//                                            resDict["smallcaseAuthToken"] = authToken
                                            resDict["transaction"] = "TRANSACTION"
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: resDict, options: [])
                                            let jsonString = String(data: jsonData, encoding: .utf8)
                                            
//                                            result(self?.getJsonStringResult(success: true, data: transData.description, errorCode: nil, errorMessage: nil, transaction: "TRANSACTION"))
                                            result(jsonString)
                                            return
                                        }
                                        
                                    } catch {
                                    
                                    }
                                    //TODO: - Handle Later
                                
                                case .holdingsImport(let smallcaseAuthToken, let status, let transactionId):

                                    result(self?.getJsonStringResult(success: true, data: "\(smallcaseAuthToken)" , errorCode: nil, errorMessage: nil, transaction: "HOLDINGS_IMPORT"))
                                    return
                                    
                                case .sipSetup(let smallcaseAuthToken, let sipDetails, let transactionId):

                                    var sipResponse: [String: Any]
                                    do{
                                        let jsonEncoder = JSONEncoder()
                                        let jsonData = try jsonEncoder.encode(sipDetails)
                                        
                                        let data = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                        
                                        if let dictionary = data as? [String: Any] {
                                            sipResponse = dictionary as! [String: Any]
                                            
                                            print("Sip response: \(sipResponse)")
                                            
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
//                                    result(self?.getJsonStringResult(success: true, data: "\(sipDetails)" , errorCode: nil, errorMessage: nil, transaction: "SIP_SETUP"))
//                                    return
                                    
                                default:
                                    return
                                }
                            
                                
                                
                            case .failure(let error):
                                
                                print("CONNECT: ERROR :\(error)")
//                                self?.showPopup(title: "Error", msg: "\(error.message)  \(error.rawValue)")
                                
                                
                                result(FlutterError.init(code: (self?.getJsonStringResult(success: false, data: nil, errorCode: error.rawValue, errorMessage: error.message, transaction: "ERROR"))!, message: nil, details: nil))
                                
                                return
                            }
                            print(gatewayResult)
                        }
                    }
                    catch SCGatewayError.uninitialized {
                        print(SCGatewayError.uninitialized.message)
                        //initialize gateway
                    }
                    catch let err {
                        print(err)
                    }
            }
    }
        
    else if(call.method == "leadGen") {
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let name = args["name"] as? String,
            let email = args["email"] as? String,
            let contact = args["contact"] as? String,
            let pinCode = args["pincode"] as? String {
            
             var params:[String:String] = [:]
                   params["name"] = name
                   params["email"] = email
                   params["contact"] = contact
                   params["pinCode"] = pinCode
                   SCGateway.shared.triggerLeadGen(presentingController: currentViewController,params: params)
            
            result("Lead Gen Success")
        } else {
            result(FlutterError.init(code: "bad args", message: "error at method leadGen", details: nil))
        }
    }
        
     else if(call.method == "getAllSmallcases") {
        
        SCGateway.shared.getSmallcases(params: nil) { [weak self] (data, error) in
            
            
            guard let response = data else {
                
                print(error ?? "No error object")
                return
                
            }
         
            let smallcasesJson = try? JSONSerialization.jsonObject(with: response, options: [])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
            
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            result(jsonString)
        }
        
     }
        
    else if(call.method == "getUserInvestments") {
            
        SCGateway.shared.getUserInvestments(iscids: nil) { [weak self] (data, error) in
            
            guard let response = data else {
                
                print(error ?? "No error object")
                return
                
            }
            
            let smallcasesJson = try? JSONSerialization.jsonObject(with: response, options: [])
            
            let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
            
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            result(jsonString)
            
        }
        
    }
        
     else if(call.method == "getExitedSmallcases") {
        
        SCGateway.shared.getExitedSmallcases{ [weak self] (data, error) in
            
            guard let response = data else {
                           
                           print(error ?? "No error object")
                           return
                           
                       }
                       
                       let smallcasesJson = try? JSONSerialization.jsonObject(with: response, options: [])
                       
                       let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
                       
                       let jsonString = String(data: jsonData, encoding: .utf8)
                       
                       result(jsonString)
            
        }
        
     }
        
     else if(call.method == "markArchive") {
        
        if let args = call.arguments as? Dictionary<String, Any>,
            
            let iscid = args["iscid"] as? String {
                
            
            SCGateway.shared.markSmallcaseArchive(iscid: iscid) { [weak self] (data, error) in
                
                guard let response = data else {
                                   
                                   print(error ?? "No error object")
                                   return
                                   
                               }
                               
                               let smallcasesJson = try? JSONSerialization.jsonObject(with: response, options: [])
                               
                               let jsonData = try! JSONSerialization.data(withJSONObject: smallcasesJson, options: [])
                               
                               let jsonString = String(data: jsonData, encoding: .utf8)
                               
                               result(jsonString)
                    
                }
                
            } else {
                result(FlutterError.init(code: "bad args", message: "error at method markArchive", details: nil))
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

