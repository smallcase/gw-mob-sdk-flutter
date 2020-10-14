package com.smallcase.gateway.data.models

import android.util.Log
import com.google.gson.annotations.SerializedName

data class SmallcaseTransaction(

    @SerializedName("orderConfig")
    val orderConfig: OrderConfig? = null,

    @SerializedName("expireAt")
    val expireAt: String? = null,

    @SerializedName("intent")
    val intent: String,

    @SerializedName("status")
    val status: String,

    @SerializedName("gateway")
    val gateway: String? = null,

    @SerializedName("transactionId")
    val transactionId: String? = null,

    @SerializedName("createdAt")
    val createdAt: String? = null,

    @SerializedName("updatedAt")
    val updatedAt: String? = null,

    @SerializedName("__v")
    val V: Int? = null,

    @SerializedName("authId")
    val authId: String? = null,

    @SerializedName("success")
    val success: Any? = null,

    @SerializedName("error")
    val error: GatewaySdkError? = null,

    @SerializedName("expired")
    val expired: Boolean? = false

) /*{
    fun printLN() {
        Log.i("Smallcase Transaction", "Print called")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$orderConfig ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$expireAt ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$intent ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$status ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$gateway ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$transactionId ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$createdAt ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$updatedAt ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$authId ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$V ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$success ")
        Log.i("Smallcase Transaction", "SmallcaseTransactions is :$error ")
    }
}*/

data class Success(
    val smallcaseAuthToken: String
    // val gateway_loader: String?
)
