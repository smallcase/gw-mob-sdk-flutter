package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class SmallcaseGatewayDataResponse(

    @SerializedName("success")
    val success: Boolean,
    @SerializedName("error")
    val error: List<String>? = null,
    @SerializedName("data")
    var data: Any? = null

) {
    fun getValue(): String? {
        return data?.toString()
    }
}
