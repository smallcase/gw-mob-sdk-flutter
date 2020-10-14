package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class ActionsDTO(

    @SerializedName("rebalance")
    val rebalance: List<Any?>? = null,

    @SerializedName("sell")
    val sell: List<Any?>? = null,

    @SerializedName("fix")
    val fix: List<FixDTO?>? = null,

    @SerializedName("buy")
    val buy: List<Any?>? = null,

    @SerializedName("sip")
    val sip: List<SipDTO?>? = null
)
