package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class RatiosDTO(

        @SerializedName("52wHigh")
        val jsonMember52wHigh: Any? = null,

        @SerializedName("52wLow")
        val jsonMember52wLow: Any? = null,

        @SerializedName("divYield")
        val divYield: Any? = null,

        @SerializedName("divYieldDifferential")
        val divYieldDifferential: Any? = null,

        @SerializedName("largeCapPercentage")
        val largeCapPercentage: Any? = null,

        @SerializedName("marketCapCategory")
        val marketCapCategory: String? = null,

        @SerializedName("midCapPercentage")
        val midCapPercentage: Any? = null,

        @SerializedName("pb")
        val pb: Any? = null,

        @SerializedName("pbDiscount")
        val pbDiscount: Any? = null,

        @SerializedName("pe")
        val pe: Any? = null,

        @SerializedName("peDiscount")
        val peDiscount: Any? = null,

        @SerializedName("smallCapPercentage")
        val smallCapPercentage: Any? = null,

        @SerializedName("cagr")
        val cagr: Any? = null,

        @SerializedName("momentumRank")
        val momentumRank: Any? = null,

        @SerializedName("risk")
        val risk: Any? = null,

        @SerializedName("sharpe")
        val sharpe: Any? = null,

        @SerializedName("ema")
        val ema: Any? = null,

        @SerializedName("momentum")
        val momentum: Any? = null,

        @SerializedName("lastCloseEma")
        val lastCloseEma: Any? = null,

        @SerializedName("sharpeRatio")
        val sharpeRatio: Any? = null
)
