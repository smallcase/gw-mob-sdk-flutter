import Foundation
import Flutter

class ScLoanEventsHandler: NSObject {
    
    private var eventChannel: FlutterEventChannel?
    private var eventStreamHandler: ScLoanEventsStreamHandler?
    
    func setup(with registrar: FlutterPluginRegistrar) {
        print("Setting up SCLoans events channel...")
        
        eventStreamHandler = ScLoanEventsStreamHandler()
        eventChannel = FlutterEventChannel(name: "scloans_events", binaryMessenger: registrar.messenger())
        eventChannel?.setStreamHandler(eventStreamHandler)
        
        setupNotificationListener()
        print("SCLoans events channel setup complete")
    }
    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("scloans_notification"),
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