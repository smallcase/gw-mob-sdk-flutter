package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class MarketStatusCheck(

    @SerializedName("broker")
    val broker: String? = null,

    @SerializedName("marketOpen")
    val marketOpen: Boolean? = null,

    @SerializedName("amoActive")
    val amoActive: Boolean? = null,

    @SerializedName("cancelAmoActive")
    val cancelAmoActive: Boolean? = null,

    @SerializedName("activeDays")
    val activeDays: ActiveDays? = null
)
