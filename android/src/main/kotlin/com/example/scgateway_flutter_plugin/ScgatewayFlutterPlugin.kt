package com.example.scgateway_flutter_plugin

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.SmallcaseLogoutListener
import com.smallcase.gateway.data.listeners.*
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.portal.SmallplugPartnerProps
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

/** ScgatewayFlutterPlugin */
class ScgatewayFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val TAG: String = "Android_Scgateway"

    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())

    private lateinit var context: Context
    private lateinit var activity: Activity

    private var replySubmitted = false

    internal var txnResult: String? = ""

    private val leadGenMap by lazy {
        HashMap<String, String>()
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var scLoansChannel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "scgateway_flutter_plugin")
        channel.setMethodCallHandler(this)

        scLoansChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "scloans_flutter_plugin")
        scLoansChannel.setMethodCallHandler(ScLoanFlutterPlugin(getActivity = {
            activity
        }))
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {

        val result = ScgatewayMethodChannelResult(rawResult, activity)
        replySubmitted = false

        when (call.method) {

            "setFlutterSdkVersion" -> {
                SmallcaseGatewaySdk.setSDKType("flutter")
                SmallcaseGatewaySdk.setHybridSDKVersion(call.argument("flutterSdkVersion")!!)
                result.success(true)
            }

            "getSdkVersion" -> {
                val flutterSdkVersion: String = ",flutter:" + call.argument("flutterSdkVersion")
                val nativeSdkVersion = "android:${SmallcaseGatewaySdk.getSdkVersion()}"
                result.success(nativeSdkVersion + flutterSdkVersion)
            }

            "setConfigEnvironment" -> {

                val res = JSONObject()

                val env: String? = call.argument("env")
                val gateway: String? = call.argument("gateway")
                val leprechaun: Boolean? = call.argument("leprechaun")
                val amo: Boolean? = call.argument("amo")

                val environment = when (env) {
                    "GatewayEnvironment.DEVELOPMENT" -> Environment.PROTOCOL.DEVELOPMENT
                    "GatewayEnvironment.STAGING" -> Environment.PROTOCOL.STAGING
                    else -> Environment.PROTOCOL.PRODUCTION
                }

                val customBrokerConfig: List<String>? = call.argument("brokers")

                SmallcaseGatewaySdk.setConfigEnvironment(Environment(environment, gateway!!, leprechaun!!, amo!!, customBrokerConfig!!), object : SmallcaseGatewayListeners {
                    override fun onGatewaySetupSuccessfull() {
                        res.put("success", true)
                        res.put("error", null)
                        result.success(res.toString())
                    }

                    override fun onGatewaySetupFailed(error: String) {
                        res.put("success", false)
                        res.put("error", error)

                        result.error(res.toString(), null, null)
                    }

                })
            }
            "initializeGateway" -> {

                val res = JSONObject()

                val authToken: String? = call.argument("authToken")

                SmallcaseGatewaySdk.init(InitRequest(authToken!!),

                    object : DataListener<InitialisationResponse> {
                        override fun onSuccess(authData: InitialisationResponse) {

                            res.put("success", true)
                            res.put("user connected", SmallcaseGatewaySdk.isUserConnected())
                            res.put("authToken", SmallcaseGatewaySdk.getSmallcaseAuthToken())
                            res.put("errorCode", null)
                            res.put("errorMessage", null)
                            result.success(res.toString())
                        }

                        override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {

                            res.put("errorCode", errorCode)
                            res.put("errorMessage", errorMessage)
                            res.put("data", data)
                            result.error(res.toString(), null, null)
                        }
                    })

            }
            "triggerTransaction" -> {

                val transactionId: String? = call.argument("transactionId")

                if (transactionId != null) {
                    SmallcaseGatewaySdk.triggerTransaction(activity, transactionId, object : TransactionResponseListener {
                        override fun onSuccess(transactionResult: TransactionResult) = txnOnSuccessCallback(transactionResult, result)
                        override fun onError(errorCode: Int, errorMessage: String, data: String?) = txnOnErrorCallback(errorCode, errorMessage, data, result)
                    })
                }
            }
            "triggerMfTransaction" -> {

                val transactionId: String? = call.argument("transactionId")

                if (transactionId != null) {
                    SmallcaseGatewaySdk.triggerMfTransaction(activity, transactionId, object : MFHoldingsResponseListener {
                        override fun onSuccess(transactionResult: TransactionResult) = txnOnSuccessCallback(transactionResult, result)
                        override fun onError(errorCode: Int, errorMessage: String, data: String?) = txnOnErrorCallback(errorCode, errorMessage, data, result)
                    })
                }
            }
            "leadGen" -> {

                val name: String? = call.argument("name")
                val email: String? = call.argument("email")
                val contact: String? = call.argument("contact")

                SmallcaseGatewaySdk.triggerLeadGen(activity, generateMapForLead(name, email, contact))

                result.success("Lead Gen Success")
            }
            "leadGenWithStatus" -> {

                val name: String? = call.argument("name")
                val email: String? = call.argument("email")
                val contact: String? = call.argument("contact")

                SmallcaseGatewaySdk.triggerLeadGen(activity, generateMapForLead(name, email, contact), object : LeadGenResponseListener {
                    override fun onSuccess(leadResponse: String) {
                        uiThreadHandler.post {
                            result.success(leadResponse)
                        }
                    }
                })
            }
            "triggerLeadGenWithLoginCta" -> {

                val name: String? = call.argument("name")
                val email: String? = call.argument("email")
                val contact: String? = call.argument("contact")
                val utmParams: HashMap<String, String>? = call.argument("utmParams")
                val showLoginCta: Boolean? = call.argument("showLoginCta")

                Log.d(TAG, "ctad showLoginCta: $showLoginCta")

                SmallcaseGatewaySdk.triggerLeadGen(
                 activity = activity,
                 params = generateMapForLead(name, email, contact),
                 utmParams = utmParams,
                 retargeting = null,
                 showLoginCta = showLoginCta,
                 leadStatusListener = object : LeadGenResponseListener {
                     override fun onSuccess(leadResponse: String) {
                        uiThreadHandler.post {
                            result.success(leadResponse)
                        }
                    }
                 })
            }
            "getAllSmallcases" -> {

                val res = JSONObject()

                SmallcaseGatewaySdk.getSmallcases(null, null, object : DataListener<SmallcaseGatewayDataResponse> {
                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {

                        res.put("success", false)
                        res.put("error", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)

                    }

                    override fun onSuccess(response: SmallcaseGatewayDataResponse) {

                        result.success(Gson().toJson(response).toString())

                    }

                })
            }
            "getUserInvestments" -> {

                val res = JSONObject()

                SmallcaseGatewaySdk.getUserInvestments(null, object : DataListener<SmallcaseGatewayDataResponse> {
                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {
                        res.put("success", false)
                        res.put("error", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(response: SmallcaseGatewayDataResponse) {
                        result.success(Gson().toJson(response).toString())
                    }

                })

            }
            "getSmallcaseNews" -> {

                val scid: String? = call.argument("scid")

                val res = JSONObject()

                SmallcaseGatewaySdk.getSmallcaseNews(scid, null, 200, 2, object : DataListener<SmallcaseGatewayDataResponse> {
                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {
                        res.put("success", false)
                        res.put("error", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(response: SmallcaseGatewayDataResponse) {
                        result.success(Gson().toJson(response).toString())
                    }
                })

            }
            "getExitedSmallcases" -> {

                val res = JSONObject()

                SmallcaseGatewaySdk.getExitedSmallcases(object : DataListener<SmallcaseGatewayDataResponse> {
                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {
                        res.put("success", false)
                        res.put("error", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(response: SmallcaseGatewayDataResponse) {
                        result.success(Gson().toJson(response).toString())
                    }

                })

            }
            "markArchive" -> {
                val res = JSONObject()

                val iscid: String? = call.argument("iscid")

                SmallcaseGatewaySdk.markSmallcaseArchived(iscid!!, object : DataListener<SmallcaseGatewayDataResponse> {
                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {
                        res.put("success", false)
                        res.put("error", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(response: SmallcaseGatewayDataResponse) {
                        result.success(Gson().toJson(response).toString())
                    }

                })
            }
            "logoutUser" -> {

                val res = JSONObject()

                SmallcaseGatewaySdk.logoutUser(activity, object : SmallcaseLogoutListener {

                    override fun onLogoutSuccessfull() {

                        if (!replySubmitted) {
                            result.success("Logout Successful")

                            replySubmitted = true
                        }

                    }

                    override fun onLogoutFailed(errorCode: Int, error: String) {

                        res.put("success", false)
                        res.put("error", error)

                        result.error(res.toString(), null, null)

                    }

                })

            }
            "launchSmallplug" -> {

                val targetEndpoint: String? = call.argument("targetEndpoint")
                val params: String? = call.argument("params")

                val res = JSONObject()

                SmallcaseGatewaySdk.launchSmallPlug(activity, SmallplugData(targetEndpoint, params), object : SmallPlugResponseListener {

                    override fun onFailure(errorCode: Int, errorMessage: String) {
                        res.put("success", false)
                        res.put("error", errorMessage)

                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(smallPlugResult: SmallPlugResult) {
                        uiThreadHandler.post {
                            result.success(Gson().toJson(smallPlugResult).toString())
                        }
                    }

                })
            }
            "launchSmallplugWithBranding" -> {

                val targetEndpoint: String? = call.argument("targetEndpoint")
                val params: String? = call.argument("params")
                val headerColor = call.argument<String>("headerColor")
                val headerOpacity = call.argument<Double>("headerOpacity")
                val backIconColor = call.argument<String>("backIconColor")
                val backIconOpacity = call.argument<Double>("backIconOpacity")

                val smallplugPartnerProps = SmallplugPartnerProps(headerColor ?: "#2F363F", headerOpacity ?: 1.0, backIconColor ?: "#ffffff", backIconOpacity ?: 1.0)

                val res = JSONObject()

                SmallcaseGatewaySdk.launchSmallPlug(activity, SmallplugData(targetEndpoint, params), object : SmallPlugResponseListener {

                    override fun onFailure(errorCode: Int, errorMessage: String) {
                        res.put("success", false)
                        res.put("error", errorMessage)

                        result.error(res.toString(), null, null)
                    }

                    override fun onSuccess(smallPlugResult: SmallPlugResult) {
                        uiThreadHandler.post {
                            result.success(Gson().toJson(smallPlugResult).toString())
                        }
                    }

                }, smallplugPartnerProps = smallplugPartnerProps)
            }

            "showOrders" -> {

                val res = JSONObject()

                SmallcaseGatewaySdk.showOrders(activity, null, object : DataListener<Any> {

                    override fun onSuccess(response: Any) {

                        res.put("success", true)

                        uiThreadHandler.post {
                            result.success(res.toString())
                        }

                    }

                    override fun onFailure(errorCode: Int, errorMessage: String, data: String?) {
                        res.put("errorCode", errorCode)
                        res.put("errorMessage", errorMessage)
                        res.put("data", data)
                        result.error(res.toString(), null, null)
                    }

                })
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun generateMapForLead(name: String?, email: String?, contact: String?): HashMap<String, String> {
        if (name != null && name.isNotEmpty()) {
            leadGenMap["name"] = name
        }

        if (email != null && email.isNotEmpty()) {
            leadGenMap["email"] = email
        }

        if (contact != null && contact.isNotEmpty()) {
            leadGenMap["contact"] = contact
        }

        return if (leadGenMap.isNullOrEmpty()) {
            hashMapOf()
        } else {
            leadGenMap
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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


}
