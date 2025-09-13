import Foundation
import Flutter

class ScLoanEventsStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func sendEvent(_ event: String) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(event)
        }
    }
}