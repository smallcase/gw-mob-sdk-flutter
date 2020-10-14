package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class UserDataDTO(

    @SerializedName("broker")
    val broker: BrokerDTO? = null,

    @SerializedName("investedSmallcases")
    val investedSmallcases: List<Any?>? = null,

    @SerializedName("exitedSmallcases")
    val exitedSmallcases: List<Any?>? = null,

    @SerializedName("actions")
    val actions: ActionsDTO? = null
)
