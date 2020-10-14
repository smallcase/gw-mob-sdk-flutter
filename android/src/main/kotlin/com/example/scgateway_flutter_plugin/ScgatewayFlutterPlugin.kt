package com.example.scgateway_flutter_plugin

import android.app.Activity
import android.content.Context
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.Environment
import com.smallcase.gateway.data.models.InitialisationResponse
import com.smallcase.gateway.data.models.TransactionResult
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.portal.SmallcaseGatewaySdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ScgatewayFlutterPlugin */
class ScgatewayFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private val TAG: String = "Android_Native_Scgateway"

  private lateinit var context: Context
  private lateinit var activity: Activity
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "scgateway_flutter_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    }
    
    if (call.method == "initializeGateway") {

      val environment: Int? = call.argument("env")
      val userId: String? = call.argument("userId")
      val gateway: String? = call.argument("gateway")
      val leprechaun: Boolean? = call.argument("leprechaun")
      val amo: Boolean? = call.argument("amo")
      val authToken: String? = call.argument("authToken")

      val res = setupGateway(environment, gateway, userId, leprechaun, amo, authToken)

      if(!res.isEmpty()) {
        result.success(res)
      } else {
        result.error("UNAVAILABLE", "Gateway not initialized.", null)
      }
    }
    if (call.method == "getTransactionId") {

      var intent: String? = call.argument("intent")

      val res = getGatewayIntent(intent)

      if(!res.isEmpty()) {
        result.success(res)
      } else {
        result.error("UNAVAILABLE", "Broker not Connected.", null)
      }
    }

    if(call.method == "connectToBroker") {

      var transactionId: String? = call.argument("transactionId")

      val res = triggerGatewayTransaction(transactionId)

//                if(!res.isEmpty()) {
//                    result.success(res)
//                } else {
//                    result.error("UNAVAILABLE", "Broker not Connected.", null)
//                }
    }
    else {
      result.notImplemented()
    }
  }

  private fun setupGateway(env: Int?, gateway: String?, userIdInput: String?, leprechaunMode: Boolean?, isAmoEnabled: Boolean?, smallcaseAuthToken: String?): String {

    val environment = when (env) {
      1 -> Environment.PROTOCOL.DEVELOPMENT
      2 -> Environment.PROTOCOL.STAGING
      else -> Environment.PROTOCOL.PRODUCTION
    }

    val customBrokerConfig: List<String> = arrayListOf<String>()

    SmallcaseGatewaySdk.setConfigEnvironment(
            Environment(environment, gateway!!, leprechaunMode!!, isAmoEnabled!!, customBrokerConfig),
            object : SmallcaseGatewayListeners {
              override fun onGatewaySetupSuccessfull() {

                SmallcaseGatewaySdk.init(
                        InitRequest(
                                smallcaseAuthToken!!
                        ),

                        object : DataListener<InitialisationResponse> {
                          override fun onSuccess(authData: InitialisationResponse) {

//                                        alertDialog.setMessage(
//                                                "user connected :${SmallcaseGatewaySdk.isUserConnected()}" +
//                                                        "\n broker:${if (SmallcaseGatewaySdk.getConnectedUserData() != null) {
//                                                            SmallcaseGatewaySdk.getConnectedUserData()!!.broker
//                                                        } else {
//                                                            "none"
//                                                        }}" +
//                                                        "\n authToken:${SmallcaseGatewaySdk.getSmallcaseAuthToken()}"
//
//                                        )
//                                        alertDialog.setPositiveButton(
//                                                "ok"
//                                        ) { dialog, which ->
//
//                                            // authData.toString()
//                                        }
//
//                                        alertDialog.show()
                          }

                          override fun onFailure(errorCode: Int, errorMessage: String) {
                            errorMessage.toString()
                            Log.d(TAG, "onFailure: " + errorMessage.toString())
                          }
                        }
                )
              }

              override fun onGatewaySetupFailed(error: String) {
              }

            }
    )

    return "Setup is Complete .. $env $gateway $userIdInput $leprechaunMode $isAmoEnabled $smallcaseAuthToken";
  }

  private fun getGatewayIntent(gatewayIntent: String?): String{
    return when (gatewayIntent) {
      "connect" -> SdkConstants.TransactionIntent.CONNECT
      "transaction" -> SdkConstants.TransactionIntent.TRANSACTION
      else -> SdkConstants.TransactionIntent.HOLDINGS_IMPORT
    }
  }

  private fun triggerGatewayTransaction(transactionId: String?) {

    Log.d(TAG, "SDK auth Token: " + SmallcaseGatewaySdk.getSmallcaseAuthToken())

    if(transactionId != null) {

    } else {
      // This means user is alread connected and trying to reconnect again
      // hence pass the existing user and quit the transaction
      SmallcaseGatewaySdk.setTransactionResult(TransactionResult(
              true, SmallcaseGatewaySdk.Result.CONNECT,
              SmallcaseGatewaySdk.getSmallcaseAuthToken(), null, null
      ))
    }

    triggerTransactionWithTransactionId(transactionId!!)

  }

  private fun triggerTransactionWithTransactionId(transactionId:String) {
    SmallcaseGatewaySdk.triggerTransaction(activity!!,
            transactionId,
            object : TransactionResponseListener {
              override fun onSuccess(transactionResult: TransactionResult) {

                try {
                  if (transactionResult.success) {
                    val toastString =
                            "authToken:${SmallcaseGatewaySdk.getSmallcaseAuthToken()}"

                    Toast.makeText(
                            context,
                            toastString,
                            Toast.LENGTH_LONG
                    ).show()

                    Log.d(TAG, "onSuccess: " +  transactionResult.data!!)
//                                onUserConnected(transactionResult.data!!)
                  } else {
                    Toast.makeText(
                            context,
                            transactionResult.error + " " + transactionResult.errorCode,
                            Toast.LENGTH_LONG
                    ).show()
                  }
                } catch (e: Exception) {
                  e.printStackTrace()
                }
              }

              override fun onError(errorCode: Int, errorMessage: String) {
                Toast.makeText(
                        context,
                        "$errorCode $errorMessage",
                        Toast.LENGTH_LONG
                ).show()
                errorCode.toString()
              }
            })
  }
  
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }
}
