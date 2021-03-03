package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class SmallcaseStatsDTO(

        @SerializedName("returns")
        val returns: SmallcaseReturns? = null,

        @SerializedName("indexValue")
        val indexValue: Double? = null,

        @SerializedName("unadjustedValue")
        val unadjustedValue: Double? = null,

        @SerializedName("divReturns")
        val divReturns: Double? = null,

        @SerializedName("lastCloseIndex")
        val lastCloseIndex: Double? = null,

        @SerializedName("minInvestAmount")
        val minInvestAmount: Double? = null,

        @SerializedName("ratios")
        val ratios: RatiosDTO? = null
)
