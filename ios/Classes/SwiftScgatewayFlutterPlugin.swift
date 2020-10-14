import Flutter
import UIKit

public class SwiftScgatewayFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "scgateway_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftScgatewayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
