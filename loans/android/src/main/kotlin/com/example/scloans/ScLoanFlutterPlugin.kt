package com.example.scloans

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import com.google.gson.Gson
import com.smallcase.loans.core.external.*
import com.smallcase.loans.core.external.ScLoanEnvironment
import com.smallcase.loans.core.external.ScLoan
import com.smallcase.loans.core.external.ScLoanNotification
import com.smallcase.loans.data.listeners.Notification
import com.smallcase.loans.data.listeners.NotificationCenter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import org.json.JSONObject

//class ScLoanFlutterPlugin(val getActivity: () -> Activity)
class ScLoanFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private val TAG: String = "Android_ScLoan"
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var scLoansChannel: MethodChannel
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    private var scLoanEventsHandler: ScLoanEventsHandler? = null

    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        scLoansChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "scloans")
        scLoansChannel.setMethodCallHandler(this)

                
        scLoanEventsHandler = ScLoanEventsHandler()
        scLoanEventsHandler?.onAttachedToEngine(flutterPluginBinding)

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        scLoansChannel.setMethodCallHandler(null)
                
        scLoanEventsHandler?.onDetachedFromEngine(binding)
        scLoanEventsHandler = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        val safeResult = ScLoanMethodChannelResult(result, activity)
        when (call.method) {
            "setup" -> {

                val env: Int? = call.argument("env")
                val gateway: String? = call.argument("gateway")

                val environment = when (env) {
                    0 -> ScLoanEnvironment.DEVELOPMENT
                    2 -> ScLoanEnvironment.STAGING
                    else -> ScLoanEnvironment.PRODUCTION
                }

                ScLoan.setup(
                    ScLoanConfig(environment = environment, gatewayName = gateway ?: "gatewaydemo"),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
            "apply" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.apply(
                    activity,
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
            "pay" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.pay(
                    activity,
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
            "withdraw" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.withdraw(
                    activity,
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
            "service" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.service(
                    activity,
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
            "triggerInteraction" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.triggerInteraction(
                    activity,
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            safeResult.error(error.code.toString(), error.message, error.toString())
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            safeResult.success(response.toString())
                        }

                    }
                )
            }
        }
    }
}