package com.example.scloans

import android.app.Activity
import io.flutter.plugin.common.MethodChannel

class ScLoanMethodChannelResult(val rawResult: MethodChannel.Result, val activity: Activity) : MethodChannel.Result {
    private var isResponseSubmitted = false

    override fun success(result: Any?) {
        if (isResponseSubmitted) return
        activity.runOnUiThread { 
            rawResult.success(result) 
            isResponseSubmitted = true
        }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        if (isResponseSubmitted) return
        activity.runOnUiThread { 
            rawResult.error(errorCode, errorMessage, errorDetails)
            isResponseSubmitted = true
        }
    }

    override fun notImplemented() {
        if (isResponseSubmitted) return
        activity.runOnUiThread {
            rawResult.notImplemented()
            isResponseSubmitted = true
        }
    }
}