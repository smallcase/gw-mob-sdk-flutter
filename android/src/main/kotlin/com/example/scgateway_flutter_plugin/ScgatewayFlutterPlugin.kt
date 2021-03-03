package com.example.scgateway_flutter_plugin

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.example.scgateway_flutter_plugin.models.AllSmallcasesDTO
import com.google.gson.Gson
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.Environment
import com.smallcase.gateway.data.models.InitialisationResponse
import com.smallcase.gateway.data.models.SmallcaseGatewayDataResponse
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
import org.json.JSONObject
import kotlin.collections.HashMap

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

      val res = JSONObject()
      
      val authToken: String? = call.argument("authToken")
      
      SmallcaseGatewaySdk.init(
              InitRequest(
                      authToken!!
              ),

              object : DataListener<InitialisationResponse> {
                override fun onSuccess(authData: InitialisationResponse) {

                  res.put("success", true)
                  res.put("errorCode", null)
                  res.put("errorMessage", null)
//                  result.success(authData.toString())
                  result.success(res.toString())
                }

                override fun onFailure(errorCode: Int, errorMessage: String) {
                  Log.d(TAG, "onFailure: $errorMessage")

                  
                  res.put("errorCode", errorCode)
                  res.put("errorMessage", errorMessage)
                  result.error(res.toString(), null, null)
                }
              }
      )
      
    }
    
    else if(call.method == "setConfigEnvironment") {

      val res = JSONObject()
      
      val env: String? = call.argument("env")

      Log.d(TAG, "onMethodCall: Environment = $env")

//      val userId: String? = call.argument("userId")
      val gateway: String? = call.argument("gateway")
      val leprechaun: Boolean? = call.argument("leprechaun")
      val amo: Boolean? = call.argument("amo")

      val environment = when (env) {
        "GatewayEnvironment.DEVELOPMENT" -> Environment.PROTOCOL.DEVELOPMENT
        "GatewayEnvironment.STAGING" -> Environment.PROTOCOL.STAGING
        else -> Environment.PROTOCOL.PRODUCTION
      }

      val customBrokerConfig: List<String> = arrayListOf()

      SmallcaseGatewaySdk.setConfigEnvironment(
              Environment(environment, gateway!!, leprechaun!!, amo!!, customBrokerConfig),
              object : SmallcaseGatewayListeners {
                override fun onGatewaySetupSuccessfull() {
                  res.put("success",true)
                  res.put("error", null)
                  result.success(res.toString())
                }

                override fun onGatewaySetupFailed(error: String) {
                  res.put("success", false)
                  res.put("error", error)
                  
                  result.error(res.toString(), null, null)
                }

              }
      )
    }

    else if(call.method == "triggerTransaction") {

      var transactionId: String? = call.argument("transactionId")

      if (transactionId != null) {
        SmallcaseGatewaySdk.triggerTransaction(activity!!,
                transactionId,
                object : TransactionResponseListener {
                  override fun onSuccess(transactionResult: TransactionResult) {

                    try {
                      if (transactionResult.success) {

                        Log.d(TAG, "onSuccess: " + transactionResult.data!!)

                        if(transactionResult.transaction == SmallcaseGatewaySdk.Result.HOLDING_IMPORT) {
//                          Gson().toJson(transactionResult)
                          val holdingRes = JSONObject(transactionResult.data!!)

                          val smallcaseAuthToken = holdingRes.getString("smallcaseAuthToken")

                          val res = JSONObject()

                          res.put("data", smallcaseAuthToken)
                          res.put("success", true)
                          res.put("transaction", "HOLDINGS_IMPORT")

                          result.success(res.toString())
                        } else if(transactionResult.transaction == SmallcaseGatewaySdk.Result.TRANSACTION){

                          val transRes = JSONObject(transactionResult.data!!)
                          transRes.put("success", true)
                          transRes.put("transaction", "TRANSACTION")

                          result.success(transRes.toString())
                        } else {
                          txnResult = transactionResult.data!!

                          result.success(Gson().toJson(transactionResult).toString())
                        }
                      } else {

                        txnResult = transactionResult.error + " " + transactionResult.errorCode

                        result.error(Gson().toJson(transactionResult).toString(), null, null)
//                        result.error(transactionResult.errorCode.toString(), transactionResult.error, null)
                      }
                    } catch (e: Exception) {
                      e.printStackTrace()
                    }
                  }

                  override fun onError(errorCode: Int, errorMessage: String) {

                    errorCode.toString()

                    txnResult = errorMessage

                    val res = JSONObject()
                    res.put("errorCode", errorCode)
                    res.put("errorMessage", errorMessage)

                    result.error(res.toString(), null, null)
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
    
    else if(call.method == "getAllSmallcases") {

      val res = JSONObject()
      
      SmallcaseGatewaySdk.getSmallcases(null, null, object : DataListener<SmallcaseGatewayDataResponse> {
        override fun onFailure(errorCode: Int, errorMessage: String) {

          res.put("success", false)
          res.put("error", errorMessage)

          result.error(res.toString(), null, null)

        }

        override fun onSuccess(response: SmallcaseGatewayDataResponse) {
          val gson = Gson()

          gson.fromJson<AllSmallcasesDTO>(response.getValue(gson), AllSmallcasesDTO::class.java)?.smallcases.let {
            Log.d(TAG, "onSuccess: all smallcases: $it")

//            res.put("smallcases", it)
            result.success(Gson().toJson(response).toString())
          }
        }

      })
      
//      result.success("gotSmallcases")
    }

    else if(call.method == "getSmallcaseNews") {

      val scid: String? = call.argument("scid")

      val res = JSONObject()

      SmallcaseGatewaySdk.getSmallcaseNews(scid, null, 200, 2, object : DataListener<SmallcaseGatewayDataResponse> {
        override fun onFailure(errorCode: Int, errorMessage: String) {

          res.put("success", false)
          res.put("error", errorMessage)

          result.error(res.toString(), null, null)

        }

        override fun onSuccess(response: SmallcaseGatewayDataResponse) {
          
//            res.put("smallcases", it)
          result.success(Gson().toJson(response).toString())

        }


      })



    }
    
    else {
      result.notImplemented()
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
