package com.example.scgateway_flutter_plugin

import android.app.Activity
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import com.smallcase.loans.core.external.*
import com.smallcase.loans.core.internal.SCLoanEnvironment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class SCLoansFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private val TAG: String = "Android_SCLoans"

    private lateinit var context: Context
    private lateinit var activity: AppCompatActivity

    private lateinit var scLoansChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = binding.applicationContext

        scLoansChannel = MethodChannel(binding.binaryMessenger, "scloans_flutter_plugin")
        scLoansChannel.setMethodCallHandler(SCLoansFlutterPlugin())
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
                    1 -> SCLoanEnvironment.DEVELOPMENT
                    2 -> SCLoanEnvironment.STAGING
                    else -> SCLoanEnvironment.PRODUCTION
                }

                SCLoan.setup(
                    SCLoanConfig(environment = environment, gatewayName = gateway ?: "gatewaydemo"),
                    listener = object : SCLoanResult {
                        override fun onFailure(error: SCLoanError) {
                            res.put("success", false)
                            res.put("error", error)

                            result.error(res.toString(), null, null)

                        }

                        override fun onSuccess(response: SCLoanSuccess) {
                            res.put("success", true)
                            res.put("error", null)
                            result.success(res.toString())
                        }

                    }
                )
            }
            "apply" -> {
                val interactionToken: String? = call.argument("interactionToken")

                SCLoan.apply(
                    activity,
                    SCLoanInfo(interactionToken ?: ""),
                    listener = object : SCLoanResult {
                        override fun onFailure(error: SCLoanError) {
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: SCLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
                        }

                    }
                )
            }
            "pay" -> {
                val interactionToken: String? = call.argument("interactionToken")

                SCLoan.pay(
                    activity,
                    SCLoanInfo(interactionToken ?: ""),
                    listener = object : SCLoanResult {
                        override fun onFailure(error: SCLoanError) {
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: SCLoanSuccess) {
                            result.success(Gson().toJson(response).toString())
                        }

                    }
                )
            }
            "withdraw" -> {
                val interactionToken: String? = call.argument("interactionToken")

                SCLoan.withdraw(
                    activity,
                    SCLoanInfo(interactionToken ?: ""),
                    listener = object : SCLoanResult {
                        override fun onFailure(error: SCLoanError) {
                            result.error(Gson().toJson(error).toString(), null, null)
                        }

                        override fun onSuccess(response: SCLoanSuccess) {
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