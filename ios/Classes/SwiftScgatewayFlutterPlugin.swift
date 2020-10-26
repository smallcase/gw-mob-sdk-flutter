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
    
    var smallcaseAuthToken: String? {
        didSet {
            if smallcaseAuthToken != nil {
//                gatewayInitialize()
            }
        }
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "scgateway_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftScgatewayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     if(call.method == "initializeGateway") {
        if let args = call.arguments as? Dictionary<String, Any>,
           
           let isLeprechaunActive = args["leprechaun"] as? Bool,
           let gateway = args["gateway"] as? String,
           let environment = args["env"] as? Int,
           let authToken = args["authToken"] as? String {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let brokerConfig: [String]? = []

                let config = GatewayConfig(gatewayName: gateway,
                                                  brokerConfig: brokerConfig ,
                                                  apiEnvironment: self.getApiEnv(index: environment),
                                                  isLeprechaunActive: isLeprechaunActive,
                                                  isAmoEnabled: true)
                
                SCGateway.shared.setup(config: config)
                
                self.smallcaseAuthToken = authToken
                
                print("Initialize gateway")
                //  gatewayName: "gatewaydemo"
                SCGateway.shared.initializeGateway(sdkToken: self.smallcaseAuthToken!) { data, error in
                    
                    if !data {
                        print(error)
                        
                        if let error = error as? TransactionError {
//                            self.showPopup(title: "Error", msg: error.message)
                            result(FlutterError.init(code: "Error", message: error.message, details: nil))
                        }
                        else {
//                            self.showPopup(title: "Error", msg: error.debugDescription)
                            result(FlutterError.init(code: "Error", message: error.debugDescription, details: nil))
                        }
                        return
                    }
                    print(data)
                }
            }
            
//            setupUser(gateway: gatewayName, environment: environment, leprechaun: isLeprechaunActive, authToken: authToken)
            
            result("success ios")
        } else {
            result(FlutterError.init(code: "bad args", message: "error at method initializeGateway", details: nil))
            }
        
        }
        
    else if (call.method == "getGatewayIntent") {
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let intent = args["intent"] as? String {
            
            let res = getGatewayIntent(intent: intent)
            
            result(res)
        } else {
            result(FlutterError.init(code: "bad args", message: "error at method getTransactionId", details: nil))
        }
    }
        
    else if (call.method == "connectToBroker") {
        if let args = call.arguments as? Dictionary<String, Any>,
        
            let transactionId = args["transactionId"] as? String {
            
                    do {
                        try SCGateway.shared.triggerTransactionFlow(transactionId: transactionId , presentingController: currentViewController) { [weak self]  gatewayResult in
                            switch gatewayResult {
                            case .success(let response):
                                print("CONNECT: RESPONSE: \(response)")
                                switch response {
                                case let .connect(authToken, _):
            //                        self?.connect(authToken: authToken)
//                                self?.showPopup(title: "Connect Complete", msg: "authToken: \(authToken)")
                                
                                self?.smallcaseAuthToken = authToken
                                
                                print("Initialize gateway")
                                                //  gatewayName: "gatewaydemo"
                                SCGateway.shared.initializeGateway(sdkToken: (self?.smallcaseAuthToken)!) { data, error in
                                                    
                                        if !data {
                                                print(error)
                                                    if let error = error as? TransactionError {
                                //                            self.showPopup(title: "Error", msg: error.message)
                                                        result(FlutterError.init(code: "Error", message: error.message, details: nil))
                                                    } else {
                                //                            self.showPopup(title: "Error", msg: error.debugDescription)
                                                            result(FlutterError.init(code: "Error", message: error.debugDescription, details: nil))
                                                        }
                                                    return
                                            }
                                        print(data)
                                    }
                                result(authToken)
                                    
                                case let .transaction(authToken, transactionData):
//                                    self?.showPopup(title: "Transaction Response", msg: " authTOken : \(authToken), \n data: \(transactionData)")
                                    result("authTOken : \(authToken), \n data: \(transactionData)")
                                    return
                                
                            
                                    //TODO: - Handle Later
                                
                                case .holdingsImport(let smallcaseAuthToken, let status, let transactionId):
//                                    self?.showPopup(title: "Holdings Response", msg: "authToken: \(smallcaseAuthToken)")
//                                    result("authToken: \(smallcaseAuthToken)")
                                    return
                                    
                                default:
                                    return
                                }
                            
                                
                                
                            case .failure(let error):
                                
                                print("CONNECT: ERROR :\(error)")
//                                self?.showPopup(title: "Error", msg: "\(error.message)  \(error.rawValue)")
                                result(FlutterError.init(code: "bad args", message: "\(error.message) \(error.rawValue)", details: nil))
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
    
    
    else {
            result("Flutter method not implemented on iOS")
        }
    }
    
//    func setupUser(gateway: String, environment: Int, leprechaun: Bool, authToken: String) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            let brokerConfig: [String]? = []
//
//            let config = GatewayConfig(gatewayName: gateway,
//                                              brokerConfig: brokerConfig ,
//                                              apiEnvironment: self.getApiEnv(index: environment),
//                                              isLeprechaunActive: leprechaun,
//                                              isAmoEnabled: true)
//
//            SCGateway.shared.setup(config: config)
//
//            self.smallcaseAuthToken = authToken
//        }
//    }
    
    func getApiEnv(index: Int) -> Environment {
        
        switch index {
        case 0:
            return .production
        case 1:
            return .development
        case 2:
            return .staging
        default:
            return .production
        }
    }
    
    func getGatewayIntent(intent: String) -> String {
        
        switch intent {
        case "connect":
            return IntentType.connect.rawValue
        case "transaction":
            return IntentType.transaction.rawValue
        default:
            return IntentType.holding.rawValue
        }
    }
    
    func gatewayInitialize() {
        
        print("Initialize gateway")
        //  gatewayName: "gatewaydemo"
        SCGateway.shared.initializeGateway(sdkToken: smallcaseAuthToken!) { data, error in
            
            if !data {
                print(error)
                
                if let error = error as? TransactionError {
                    self.showPopup(title: "Error", msg: error.message)
                }
                else {
                    self.showPopup(title: "Error", msg: error.debugDescription)
                }
                return
            }
            print(data)
        }
        
    }
    
    func showPopup(title: String? , msg: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                   let popupDialog = PopupDialog(title: title, message: msg)
//                   self?.present(popupDialog, animated: true, completion: nil)
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self?.currentViewController.present(alert, animated: true, completion: nil)
        }
    }
        
}
