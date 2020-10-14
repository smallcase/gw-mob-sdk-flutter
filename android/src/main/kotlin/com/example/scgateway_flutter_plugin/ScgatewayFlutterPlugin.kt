package com.example.scgateway_flutter_plugin

import android.util.Log
import androidx.annotation.NonNull
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.models.Environment
import com.smallcase.gateway.data.models.InitialisationResponse
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.portal.SmallcaseGatewaySdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ScgatewayFlutterPlugin */
class ScgatewayFlutterPlugin: FlutterPlugin, MethodCallHandler {

  private val TAG: String = "Android_Native_Scgateway"
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "scgateway_flutter_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
