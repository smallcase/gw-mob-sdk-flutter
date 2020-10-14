package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class InitialisationResponse(
    @SerializedName("gatewayToken")
    val gatewayToken: String? = null,
    @SerializedName("csrf")
    val csrf: String? = null
)
