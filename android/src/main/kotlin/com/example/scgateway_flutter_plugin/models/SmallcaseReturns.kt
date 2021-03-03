package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class SmallcaseReturns(
        @SerializedName("daily")
        val daily: Double? = null,

        @SerializedName("weekly")
        val weekly: Double? = null,

        @SerializedName("monthly")
        val monthly: Double? = null,

        @SerializedName("yearly")
        val yearly: Double? = null
)
