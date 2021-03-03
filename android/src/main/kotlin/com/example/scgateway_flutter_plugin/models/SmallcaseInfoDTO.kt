package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class SmallcaseInfoDTO(

        @SerializedName("type")
        val type: String? = null,

        @SerializedName("name")
        val name: String? = null,

        @SerializedName("shortDescription")
        val shortDescription: String? = null,

        @SerializedName("publisherName")
        val publisherName: String? = null,

        @SerializedName("blogURL")
        val blogURL: String? = null,

        @SerializedName("nextUpdate")
        val nextUpdate: String? = null,

        @SerializedName("rebalanceSchedule")
        val rebalanceSchedule: String? = null,

        @SerializedName("lastRebalanced")
        val lastRebalanced: String? = null
)