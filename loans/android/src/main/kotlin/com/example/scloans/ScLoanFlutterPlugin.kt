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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
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

    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        scLoansChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "scloans")
        scLoansChannel.setMethodCallHandler(this)
        // scLoansChannel.setMethodCallHandler(ScLoanFlutterPlugin(getActivity = {
        //     activity
        // }))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        scLoansChannel.setMethodCallHandler(null)
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

    // colorScheme rides the bridge as a primitive string and is mapped back to the native
    // enum here. Unknown/absent → null so the SDK keeps its light-default behaviour.
    private fun parseColorScheme(value: String?): ScLoanColorScheme? = when (value) {
        "dark" -> ScLoanColorScheme.DARK
        "light" -> ScLoanColorScheme.LIGHT
        "system" -> ScLoanColorScheme.SYSTEM
        else -> null
    }

    private fun buildLoanInfo(call: MethodCall): ScLoanInfo {
        val interactionToken: String = call.argument("interactionToken") ?: ""
        val colorScheme = parseColorScheme(call.argument("colorScheme"))
        return ScLoanInfo(interactionToken, colorScheme)
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
                ScLoan.apply(
                    activity,
                    buildLoanInfo(call),
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
                ScLoan.pay(
                    activity,
                    buildLoanInfo(call),
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
                ScLoan.withdraw(
                    activity,
                    buildLoanInfo(call),
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
                ScLoan.service(
                    activity,
                    buildLoanInfo(call),
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
                ScLoan.triggerInteraction(
                    activity,
                    buildLoanInfo(call),
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