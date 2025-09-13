import Foundation
import Flutter

class ScgatewayEventsHandler: NSObject {
    
    private var eventChannel: FlutterEventChannel?
    private var eventStreamHandler: ScgatewayEventsStreamHandler?
    
    func setup(with registrar: FlutterPluginRegistrar) {
        print("Setting up SCGateway events channel...")
        
        eventStreamHandler = ScgatewayEventsStreamHandler()
        eventChannel = FlutterEventChannel(name: "scgateway_events", binaryMessenger: registrar.messenger())
        eventChannel?.setStreamHandler(eventStreamHandler)
        
        setupNotificationListener()
        print("SCGateway events channel setup complete")
    }
    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("scg_notification"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleNotification(notification)
        }
    }
    
    private func handleNotification(_ notification: Notification) {
        guard let eventStreamHandler = eventStreamHandler,
              let userInfo = notification.userInfo,
              let jsonString = userInfo["payload_str"] as? String else { return }
        
        eventStreamHandler.sendEvent(jsonString)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        eventChannel?.setStreamHandler(nil)
    }
}