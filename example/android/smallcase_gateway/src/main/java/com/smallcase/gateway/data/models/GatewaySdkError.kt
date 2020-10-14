package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class GatewaySdkError(

    @SerializedName("value")
    val value: Boolean,

    @SerializedName("code")
    val code: Int? = null,
    @SerializedName("message")
    val message: String? = null

)
