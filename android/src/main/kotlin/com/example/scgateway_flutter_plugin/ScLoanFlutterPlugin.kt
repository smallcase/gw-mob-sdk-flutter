package com.example.scgateway_flutter_plugin

import android.app.Activity
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import com.smallcase.loans.core.external.*
import com.smallcase.loans.core.internal.ScLoanEnvironment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class ScLoanFlutterPlugin(val getActivity: () -> Activity): MethodChannel.MethodCallHandler {

    private val TAG: String = "Android_ScLoan"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

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
                            result.error(error.toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(response.toString())
                        }

                    }
                )
            }
            "apply" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.apply(
                    getActivity(),
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            result.error(error.toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(response.toString())
                        }

                    }
                )
            }
            "pay" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.pay(
                    getActivity(),
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            result.error(error.toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(response.toString())
                        }

                    }
                )
            }
            "withdraw" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.withdraw(
                    getActivity(),
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            result.error(error.toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(response.toString())
                        }

                    }
                )
            }
            "service" -> {
                val interactionToken: String? = call.argument("interactionToken")

                ScLoan.service(
                    getActivity(),
                    ScLoanInfo(interactionToken ?: ""),
                    listener = object : ScLoanResult {
                        override fun onFailure(error: ScLoanError) {
                            result.error(error.toString(), null, null)
                        }

                        override fun onSuccess(response: ScLoanSuccess) {
                            result.success(response.toString())
                        }

                    }
                )
            }
        }
    }
}