package com.example.scgateway_flutter_plugin

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class ScgatewayEventsStreamHandler : EventChannel.StreamHandler {
    
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
    
    // Call this method to send data to Flutter
    fun sendEvent(data: Any) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }
    
    // Call this method to send error to Flutter
    fun sendError(errorCode: String, errorMessage: String?, errorDetails: Any? = null) {
        mainHandler.post {
            eventSink?.error(errorCode, errorMessage, errorDetails)
        }
    }
}

