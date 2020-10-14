package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class BrokerRedirectParams(
    @SerializedName("redirectParams")
    val redirectParams: String? = null
)
