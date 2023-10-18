package com.example.scgateway_flutter_plugin

import android.app.Activity
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import com.smallcase.loans.core.external.*
import com.smallcase.loans.core.internal.ScLoanEnvironment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class ScLoanFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private val TAG: String = "Android_ScLoan"

    private lateinit var context: Context
    private lateinit var activity: AppCompatActivity

    private lateinit var scLoansChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = binding.applicationContext

        scLoansChannel = MethodChannel(binding.binaryMessenger, "scloans_flutter_plugin")
        scLoansChannel.setMethodCallHandler(ScLoanFlutterPlugin())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        scLoansChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        when (call.method) {
            "setup" -> {

                val res = JSONObject()
                val env: Int? = call.argument("env")
                val gateway: String? = call.argument("gateway")

                val environment = when (env) {
                    1 -> ScLoanEnvironment.DEVELOPMENT
                    2 -> ScLoanEnvironment.STAGING
                    else -> ScLoanEnvironment.PRODUCTION
                }

                ScLoan.setup(
                    ScLoanConfig(environment = environment, gatewayName = gateway ?: "gatewaydemo"),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            res.put("success", false)
                            res.put("error", error)

                            result.error(res.toString(), null, null)

                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            res.put("success", true)
                            res.put("error", null)
                            result.success(res.toString())
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
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
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
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
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
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
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
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
                        }

                    }
                )
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity as AppCompatActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }
}