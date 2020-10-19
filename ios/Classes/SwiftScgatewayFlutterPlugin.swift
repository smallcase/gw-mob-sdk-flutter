import Flutter
import UIKit
import SCGateway

public class SwiftScgatewayFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "scgateway_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftScgatewayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "getPlatformVersion") {
        result("iOS " + UIDevice.current.systemVersion)
    }
    else if(call.method == "initializeGateway") {
        if let args = call.arguments as? Dictionary<String, Any>,
           
           let isLeprechaunActive = args["leprechaun"] as? Bool,
           let gatewayName = args["gateway"] as? String,
           let environment = args["env"] as? Int {
            result("success ios")
        } else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
        }
        
        } else {
            result("Flutter method not implemented on iOS")
        }
    }
    
    func setupUser(gateway: String, environment: Int, leprechaun: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let brokerConfig = []
                   
            let config = GatewayConfig(gatewayName: gateway,
                                              brokerConfig: brokerConfig ,
                                              apiEnvironment: self.getApiEnv(index: environment),
                                              isLeprechaunActive: leprechaun,
                                              isAmoEnabled: true)
            SCGateway.shared.setup(config: config)
        }
       
    }
}
