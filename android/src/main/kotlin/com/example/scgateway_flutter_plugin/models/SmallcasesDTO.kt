package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class SmallcasesDTO(

        @SerializedName("info")
        val info:SmallcaseInfoDTO? = null,

        @SerializedName("stats")
        val stats: SmallcaseStatsDTO? = null,

        @SerializedName("_id")
        val id: String? = null,

        @SerializedName("scid")
        val scid: String? = null,

        @SerializedName("newsTag")
        val newsTag: String? = null,

        @SerializedName("initialIndex")
        val initialIndex: Any? = null,

        @SerializedName("keywordsMatchCount")
        val keywordsMatchCount: Int? = null
)
