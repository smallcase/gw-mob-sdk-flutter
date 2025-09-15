package com.example.scgateway_flutter_plugin

import android.util.Log
import com.smallcase.gateway.data.listeners.Notification
import com.smallcase.gateway.data.listeners.NotificationCenter
import com.smallcase.gateway.portal.ScgNotification
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class ScgatewayEventsHandler : FlutterPlugin {
    
    private val TAG = "ScgatewayEventsHandler"
    private lateinit var eventChannel: EventChannel
    private lateinit var eventStreamHandler: ScgatewayEventsStreamHandler
    private var notificationObserver: ((Notification) -> Unit)? = null
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setup(flutterPluginBinding)
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        cleanup()
    }
    
    private fun setup(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventStreamHandler = ScgatewayEventsStreamHandler()
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "scgateway_events")
        eventChannel.setStreamHandler(eventStreamHandler)
        
        setupNotificationListener()
        Log.d(TAG, "SCGateway events channel setup complete")
    }
    
    private fun setupNotificationListener() {
        notificationObserver?.let { NotificationCenter.removeObserver(it) }
        
        notificationObserver = { notification ->
            try {
                val jsonString = notification.userInfo?.get(ScgNotification.STRINGIFIED_PAYLOAD_KEY) as? String
                if (jsonString != null) {
                    Log.d(TAG, "Sending notification to Flutter: $jsonString")
                    eventStreamHandler.sendEvent(jsonString)
                } else {
                    Log.w(TAG, "Notification has no JSON payload")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing notification: ${e.message}")
                eventStreamHandler.sendError("NOTIFICATION_PARSE_ERROR", e.message, e.toString())
            }
        }
        
        notificationObserver?.let { 
            NotificationCenter.addObserver(it)
            Log.d(TAG, "Notification observer added")
        }
    }
    
    private fun cleanup() {
        try {
            notificationObserver?.let { 
                NotificationCenter.removeObserver(it)
                Log.d(TAG, "Notification observer removed")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error removing notification observer: ${e.message}")
        }
        
        notificationObserver = null
        eventChannel.setStreamHandler(null)
        Log.d(TAG, "SCGateway events cleanup complete")
    }
}