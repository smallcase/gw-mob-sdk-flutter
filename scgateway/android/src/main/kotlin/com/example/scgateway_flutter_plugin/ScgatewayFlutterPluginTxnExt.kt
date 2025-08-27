package com.example.scgateway_flutter_plugin

import android.util.Log
import com.google.gson.Gson
import com.smallcase.gateway.data.models.TransactionResult
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import org.json.JSONObject

fun ScgatewayFlutterPlugin.txnOnSuccessCallback(transactionResult: TransactionResult, result: ScgatewayMethodChannelResult) {
    try {
        when (transactionResult.transaction) {
            SmallcaseGatewaySdk.Result.HOLDING_IMPORT -> {
                val holdingRes = JSONObject(transactionResult.data!!)

                val smallcaseAuthToken = holdingRes.getString("smallcaseAuthToken")
                val broker = holdingRes.getString("broker")

                val res = JSONObject()

                res.put("data", smallcaseAuthToken)
                res.put("broker", broker)
                res.put("success", true)
                res.put("transaction", "HOLDINGS_IMPORT")

                result.success(res.toString())
            }
            SmallcaseGatewaySdk.Result.TRANSACTION -> {

                val transRes = JSONObject(transactionResult.data!!)
                transRes.put("success", true)
                transRes.put("transaction", "TRANSACTION")

                result.success(transRes.toString())
            }
            SmallcaseGatewaySdk.Result.CONNECT -> {
                val res = JSONObject()

                try {

                    res.put("data", transactionResult.data!!)
                } catch (e: Exception) {
                    val smallcaseAuthToken = transactionResult.data!!

                    res.put("data", smallcaseAuthToken)
                }

                res.put("success", true)
                res.put("transaction", "CONNECT")

                result.success(res.toString())
            }
            SmallcaseGatewaySdk.Result.SIP_SETUP -> {

                val transRes = JSONObject(transactionResult.data!!)
                transRes.put("success", true)
                transRes.put("transaction", "SIP_SETUP")

                result.success(transRes.toString())

            }
            else -> {

                txnResult = transactionResult.data!!

                result.success(Gson().toJson(transactionResult).toString())
            }
        }

    } catch (e: Exception) {
        e.printStackTrace()
    }
}

fun ScgatewayFlutterPlugin.txnOnErrorCallback(errorCode: Int, errorMessage: String, data: String?, result: ScgatewayMethodChannelResult) {
    Log.d("Debug", "$data")

    errorCode.toString()

    txnResult = errorMessage

    val res = JSONObject()
    res.put("errorCode", errorCode)
    res.put("errorMessage", errorMessage)
    res.put("data", data)

    result.error(res.toString(), null, null)
}




