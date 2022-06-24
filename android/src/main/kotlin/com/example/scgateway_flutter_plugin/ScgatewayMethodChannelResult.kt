package com.example.scgateway_flutter_plugin

import android.app.Activity
import io.flutter.plugin.common.MethodChannel

class ScgatewayMethodChannelResult(val rawResult: MethodChannel.Result, val activity: Activity) : MethodChannel.Result {
    override fun success(result: Any?) {
        activity.runOnUiThread { rawResult.success(result) }
    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        activity.runOnUiThread { rawResult.error(errorCode, errorMessage, errorDetails) }
    }

    override fun notImplemented() {
        activity.runOnUiThread {
            rawResult.notImplemented()
        }
    }
}