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
  
  private var txnResult: String? = ""

  private val leadGenMap by lazy {
    HashMap<String,String>()
  }
  
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
    
    if (call.method == "initializeGateway") {

      val env: Int? = call.argument("env")
      val userId: String? = call.argument("userId")
      val gateway: String? = call.argument("gateway")
      val leprechaun: Boolean? = call.argument("leprechaun")
      val amo: Boolean? = call.argument("amo")
      val authToken: String? = call.argument("authToken")

//      val res = setupGateway(environment, gateway, userId, leprechaun, amo, authToken)

      val environment = when (env) {
        1 -> Environment.PROTOCOL.DEVELOPMENT
        2 -> Environment.PROTOCOL.STAGING
        else -> Environment.PROTOCOL.PRODUCTION
      }

      val customBrokerConfig: List<String> = arrayListOf()

      SmallcaseGatewaySdk.setConfigEnvironment(
              Environment(environment, gateway!!, leprechaun!!, amo!!, customBrokerConfig),
              object : SmallcaseGatewayListeners {
                override fun onGatewaySetupSuccessfull() {

                  SmallcaseGatewaySdk.init(
                          InitRequest(
                                  authToken!!
                          ),

                          object : DataListener<InitialisationResponse> {
                            override fun onSuccess(authData: InitialisationResponse) {
                                  
                              result.success(authData.toString())
                            }

                            override fun onFailure(errorCode: Int, errorMessage: String) {
                              errorMessage.toString()
                              Log.d(TAG, "onFailure: " + errorMessage.toString())
                              
                              result.error(errorCode.toString(), errorMessage, null)
                            }
                          }
                  )
                }

                override fun onGatewaySetupFailed(error: String) {
                  result.error(null, error, null)
                }

              }
      )
      
//      if(!res.isEmpty()) {
//        result.success(res)
//      } else {
//        result.error("UNAVAILABLE", "Gateway not initialized.", null)
//      }
    }
    else if (call.method == "getGatewayIntent") {

      var intent: String? = call.argument("intent")

      val res = getGatewayIntent(intent)

      if(!res.isEmpty()) {
        result.success(res)
      } else {
        result.error("UNAVAILABLE", "Broker not Connected.", null)
      }
    }

    else if(call.method == "connectToBroker") {

      var transactionId: String? = call.argument("transactionId")

      if(transactionId == null) {

        // This means user is already connected and trying to reconnect again
        // hence pass the existing user and quit the transaction
        
        SmallcaseGatewaySdk.setTransactionResult(TransactionResult(
                true, SmallcaseGatewaySdk.Result.CONNECT,
                SmallcaseGatewaySdk.getSmallcaseAuthToken(), null, null
        ))
      } /*else {
        
        SmallcaseGatewaySdk.setTransactionResult(TransactionResult(
                true, SmallcaseGatewaySdk.Result.CONNECT,
                SmallcaseGatewaySdk.getSmallcaseAuthToken(), null, null
        ))
      }*/

      
//      if (transactionId != null) {
      else {
        SmallcaseGatewaySdk.triggerTransaction(activity!!,
                transactionId,
                object : TransactionResponseListener {
                  override fun onSuccess(transactionResult: TransactionResult) {

                    try {
                      if (transactionResult.success) {
//                        val toastString =
//                                "authToken:${SmallcaseGatewaySdk.getSmallcaseAuthToken()}"

//                        Toast.makeText(
//                                context,
//                                transactionResult.toString(),
//                                Toast.LENGTH_LONG
//                        ).show()

                        Log.d(TAG, "onSuccess: " + transactionResult.data!!)

                        txnResult = transactionResult.data!!

                        result.success(transactionResult.data!!)
                      } else {
//                        Toast.makeText(
//                                context,
//                                transactionResult.error + " " + transactionResult.errorCode,
//                                Toast.LENGTH_LONG
//                        ).show()

                        txnResult = transactionResult.error + " " + transactionResult.errorCode

                        result.error(transactionResult.errorCode.toString(), transactionResult.error, null)
                      }
                    } catch (e: Exception) {
                      e.printStackTrace()
                    }
                  }

                  override fun onError(errorCode: Int, errorMessage: String) {
//                    Toast.makeText(
//                            context,
//                            "$errorCode $errorMessage",
//                            Toast.LENGTH_LONG
//                    ).show()
                    errorCode.toString()

                    txnResult = errorMessage

                    result.error(errorCode.toString(), errorMessage, null)
                  }
                })
      }
    }

    else if(call.method == "leadGen") {

      val name: String? = call.argument("name")
      val email: String? = call.argument("email")
      val contact: String? = call.argument("contact")
      val pincode: String? = call.argument("pincode")

      val res = generateLead(name, email, contact, pincode)

      if (res != null) {
        if(!res.isEmpty()) {
          result.success(res)
        } else {
          result.error("UNAVAILABLE", "Broker not Connected.", null)
        }
      }

    }
    else {
      result.notImplemented()
    }
  }

//  private fun setupGateway(env: Int?, gateway: String?, userIdInput: String?, leprechaunMode: Boolean?, isAmoEnabled: Boolean?, smallcaseAuthToken: String?): String {
//
//    val environment = when (env) {
//      1 -> Environment.PROTOCOL.DEVELOPMENT
//      2 -> Environment.PROTOCOL.STAGING
//      else -> Environment.PROTOCOL.PRODUCTION
//    }
//
//    val customBrokerConfig: List<String> = arrayListOf<String>()
//
//    SmallcaseGatewaySdk.setConfigEnvironment(
//            Environment(environment, gateway!!, leprechaunMode!!, isAmoEnabled!!, customBrokerConfig),
//            object : SmallcaseGatewayListeners {
//              override fun onGatewaySetupSuccessfull() {
//
//                SmallcaseGatewaySdk.init(
//                        InitRequest(
//                                smallcaseAuthToken!!
//                        ),
//
//                        object : DataListener<InitialisationResponse> {
//                          override fun onSuccess(authData: InitialisationResponse) {
//
//                          }
//
//                          override fun onFailure(errorCode: Int, errorMessage: String) {
//                            errorMessage.toString()
//                            Log.d(TAG, "onFailure: " + errorMessage.toString())
//                          }
//                        }
//                )
//              }
//
//              override fun onGatewaySetupFailed(error: String) {
//              }
//
//            }
//    )
//
//    return "Setup is Complete .. $env $gateway $userIdInput $leprechaunMode $isAmoEnabled $smallcaseAuthToken";
//  }

  private fun getGatewayIntent(gatewayIntent: String?): String{
    return when (gatewayIntent) {
      "connect" -> SdkConstants.TransactionIntent.CONNECT
      "transaction" -> SdkConstants.TransactionIntent.TRANSACTION
      else -> SdkConstants.TransactionIntent.HOLDINGS_IMPORT
    }
  }

  private fun generateLead(name: String?, email: String?, contact: String?, pincode: String?) : String? {
    
    if(name != null && name.isNotEmpty()) {
      leadGenMap.put("name", name)
    }
    
    if(email != null && email.isNotEmpty()) {
      leadGenMap.put("email", email)
    }
    
    if(contact != null && contact.isNotEmpty()) {
      leadGenMap.put("contact", contact)
    }
    
    if(pincode != null && pincode.isNotEmpty()) {
      leadGenMap.put("pinCode", pincode)
    }

    SmallcaseGatewaySdk.triggerLeadGen(activity!!,leadGenMap)
    
    return "Lead Gen Success"
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
