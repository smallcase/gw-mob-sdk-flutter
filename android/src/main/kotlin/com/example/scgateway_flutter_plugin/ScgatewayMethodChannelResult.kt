package com.example.scgateway_flutter_plugin

import android.app.Activity
import io.flutter.plugin.common.MethodChannel

class ScgatewayMethodChannelResult(val rawResult: MethodChannel.Result, val activity: Activity) : MethodChannel.Result {
    private var isResponseSubmitted = false

    override fun success(result: Any?) {
        activity.runOnUiThread { 
            rawResult.success(result) 
            isResponseSubmitted = true
        }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        activity.runOnUiThread { 
            rawResult.error(errorCode, errorMessage, errorDetails)
            isResponseSubmitted = true
        }
    }

    override fun notImplemented() {
        activity.runOnUiThread {
            rawResult.notImplemented()
            isResponseSubmitted = true
        }
    }
}