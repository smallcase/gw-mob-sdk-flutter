package com.smallcase.gateway.data.requests

import com.google.gson.annotations.SerializedName
import com.smallcase.gateway.data.SdkConstants

/**
 *Default error mark request
 **/
data class MarkTranxAsErroredRequest(

    @SerializedName("transactionId")
    val transactionId: String? = null,

    @SerializedName("errorMessage")
    val errorMessage: String? = SdkConstants.CompletionStatus.USER_CANCELLED,

    @SerializedName("errorCode")
    val errorCode: Int? = SdkConstants.ErrorCode.USER_CANCELLED,

    @SerializedName("status")
    val status: String? = SdkConstants.CompletionStatus.ERRORED
)
