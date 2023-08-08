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
      
      switch (call.method) {
              
          case "setFlutterSdkVersion": do {
              if let args = call.arguments as? Dictionary<String, Any> {
                  SCGateway.shared.setSDKType(type: "flutter")
                  SCGateway.shared.setHybridSDKVersion(version: args["flutterSdkVersion"] as! String)
                  result("success")
              }
          }
          
          case "getSdkVersion" : do {
              if let args = call.arguments as? Dictionary<String, Any> {
                  let scgatewayFlutterPluginVersion = "ios:\(SCGateway.shared.getSdkVersion()),flutter:\(args["flutterSdkVersion"] as! String)"
                  result(scgatewayFlutterPluginVersion)
              }
          }
              
        //MARK: Set Config Environment
          case "setConfigEnvironment" : do {
              
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
              
        //MARK: Initialize SDK
          case "initializeGateway": do {
              
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
                          
                          result(
                            self.getJsonStringResult(
                                success: true,
                                data: nil,
                                errorCode: nil,
                                errorMessage: nil,
                                transaction: nil
                            )
                          )
                          
                          print(success)
                      }
                      
                  }
              }
              
              
          }
              
        //MARK: Trigger Transaction
          case "triggerTransaction": do {
              
              if let args = call.arguments as? Dictionary<String, Any>,
                 
                    let transactionId = args["transactionId"] as? String {
                  
                  do {
                      
                      try SCGateway.shared.triggerTransactionFlow(transactionId: transactionId , presentingController: currentViewController) { [weak self]  gatewayResult in
                          
                          print(gatewayResult)
                          
                          switch gatewayResult {
                                  
                              case .success(let response):
                                  
                                  switch response {
                                          
                                          // MARK: CONNECT
                                      case let .connect(connectTxnResponse):
                                          
                                          let connectData = Data(connectTxnResponse.utf8)
                                          
                                          do {
                                              
                                              if let connectResponseJson = try JSONSerialization.jsonObject(with: connectData, options: []) as? [String: Any] {
                                                  
                                                  if connectResponseJson["smallcaseAuthToken"] is String {
                                                      
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
                                          
                                          // MARK: TRANSACTION
                                      case let .transaction(_, transactionData):
                                          
                                          do {
                                              let jsonEncoder = JSONEncoder()
                                              
                                              let jsonData = try jsonEncoder.encode(transactionData)
                                              
                                              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                              
                                              if let transactionSuccessData = jsonObject as? [String: Any] {
                                                  
                                                  var response : [String: Any] = transactionSuccessData
                                                  
                                                  response["success"] = true
                                                  response["transaction"] = "TRANSACTION"
                                                  
                                                  let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
                                                  let jsonString = String(data: jsonData, encoding: .utf8)
                                                  
                                                  result(jsonString)
                                                  
                                                  return
                                              }
                                              
                                          } catch {
                                              
                                          }
                                          
                                          // MARK: HOLDINGS_IMPORT
                                      case .holdingsImport(let smallcaseAuthToken, let broker, _, _, let signup):
                                          
                                          var holdingsResponse : [String: Any] = [:]
                                          
                                          holdingsResponse["smallcaseAuthToken"] = smallcaseAuthToken
                                          holdingsResponse["broker"] = broker
                                          holdingsResponse["signup"] = signup
                                          
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
                                          
                                          // MARK: SIP_SETUP
                                      case .sipSetup(let smallcaseAuthToken, let sipDetails, let transactionId, let signup):
                                          
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
                                                  resDict["transactionId"] = transactionId
                                                  resDict["signup"] = signup
                                                  
                                                  let jsonData = try! JSONSerialization.data(withJSONObject: resDict, options: [])
                                                  let jsonString = String(data: jsonData, encoding: .utf8)
                                                  
                                                  result(jsonString)
                                                  
                                                  return
                                              }
                                              
                                          } catch {
                                              /// Catch exception
                                          }
                                          
                                      default:
                                          return
                                  }
                                  
                                  
                                  //MARK: Transaction Error
                              case .failure(let error):
                                  
                                  print("TRANSACTION ERROR :\(error)")
                                  
                                  result(
                                    FlutterError.init(
                                        code: (
                                            self?.getJsonStringResult(
                                                success: false,
                                                data: error.data,
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
//                  catch SCGatewayError.uninitialized {
//                      print(SCGatewayError.uninitialized.errorMessage)
//                  }
                  catch let err {
                      print(err)
                  }
              }
              
          }
              
        //MARK: Trigger MF Transaction
          case "triggerMfTransaction": do {
              
              if let args = call.arguments as? Dictionary<String, Any>,
                 let transactionId:  String  = args["transactionId"] as? String {
                  do {
                      try SCGateway.shared.triggerMfTransaction(presentingController: currentViewController, transactionId: transactionId) { [weak self]  gatewayResult in
                          switch(gatewayResult) {
                              case .success(let response):
                                  switch response {
                                      case let .mfHoldingsImport(data) :
                                          result(data)
                                      default : return
                                  }
                              case .failure(let error):
                                  print("MF TRANSACTION ERROR :\(error)")
                                  
                                  result(
                                    FlutterError.init(
                                        code: (
                                            self?.getJsonStringResult(
                                                success: false,
                                                data: error.data,
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
//                  catch SCGatewayError.uninitialized {
//                      print(SCGatewayError.uninitialized.errorMessage)
//                  }
                  catch let err {
                      print(err)
                  }
              }
              
          }
        
        //MARK: Lead Gen
          case "leadGen": do {
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
          case "leadGenWithStatus": do {
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

        //MARK: Lead Gen with loginCTA
          case "triggerLeadGenWithLoginCta": do {
              if let args = call.arguments as? Dictionary<String, Any>,
                 
                 let name = args["name"] as? String,
                 let email = args["email"] as? String,
                 let contact = args["contact"] as? String,
                 let utmParams = args["utmParams"] as? Dictionary<String, String>,
                 let showLoginCta = args["showLoginCta"] as? Bool?
                  {

                    // var utmParams:[String:String] = [:]
                  
                  var params:[String:String] = [:]
                  params["name"] = name
                  params["email"] = email
                  params["contact"] = contact

                  SCGateway.shared.triggerLeadGen(presentingController: currentViewController, params: params, utmParams: utmParams, retargeting: false, showLoginCta: showLoginCta ?? false) { leadStatus in
                      result(leadStatus)
                  }
              } else {
                  result(FlutterError.init(code: "bad args", message: "error at method triggerLeadGenWithLoginCta", details: nil))
              }
          }
              
        //MARK: Get All Smallcases
          case "getAllSmallcases": do {
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
          case "getUserInvestments": do {
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
          case "getExitedSmallcases": do {
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
          case "markArchive": do {
              
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
          case "logoutUser": do {
              
              SCGateway.shared.logoutUser(presentingController: currentViewController) { success, error in
                  
                  if(success) {
                      result("Logout successful")
                  } else {
                      result(FlutterError.init(code: "bad args", message: "error at method logout user", details: nil))
                      
                  }
              }
          }
              
        //MARK: Launch smallplug
          case "launchSmallplug": do {
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
              
        //MARK: Launch smallplug branding
          case "launchSmallplugWithBranding": do {
              if let args = call.arguments as? Dictionary<String, Any> {
                  let target = args["targetEndpoint"] as? String
                  let params = args["params"] as? String
                  
                  var headerColor = "2F363F"
                  if let headerClr = args["headerColor"] as? String {
                      headerColor = headerClr.deletingPrefix("#")
                  }
                  
                  var headerColorOpacity = 1 as NSNumber
                  if let headerClrAlpha = args["headerOpacity"] as? NSNumber {
                      headerColorOpacity = headerClrAlpha
                  }
                  
                  var backIconColor = "FFFFFF"
                  if let bckIconClr = args["backIconColor"] as? String {
                      backIconColor = bckIconClr.deletingPrefix("#")
                  }
                  
                  var backIconOpacity = 1 as NSNumber
                  if let bckIconAlpha = args["backIconOpacity"] as? NSNumber {
                      backIconOpacity = bckIconAlpha
                  }
                  
                  SCGateway.shared.launchSmallPlug(
                    presentingController: currentViewController,
                    smallplugData: SmallplugData(target, params),
                    smallplugUiConfig: SmallplugUiConfig(
                        smallplugHeaderColor: headerColor,
                        headerColorOpacity: headerColorOpacity,
                        backIconColor: backIconColor,
                        backIconColorOpacity: backIconOpacity),
                    completion: {
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
          case "showOrders": do {
                  
                  SCGateway.shared.showOrders(presentingController: currentViewController) { success, error in
                      
                      if success {
                          result(self.getJsonStringResult(success: true, data: nil, errorCode: nil, errorMessage: nil, transaction: nil))
                      } else {
                          
                          if let showOrdersError = error as? ObjcTransactionError {
                              result(
                                self.getJsonStringResult(
                                    success: false,
                                    data: showOrdersError.userInfo.toJsonString,
                                    errorCode: showOrdersError.code,
                                    errorMessage: showOrdersError.domain,
                                    transaction: nil
                                )
                              )
                          }
                          
                      }
                  }
              }
          
          //MARK: LAMF
          
              
          default:
              result("Flutter method not implemented on iOS")
      }
      
    }
    
    
    //MARK: Utility Methods
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
