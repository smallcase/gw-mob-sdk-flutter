package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class ActiveDays(

    @SerializedName("isWorkingDay")
    val isWorkingDay: Boolean? = null,

    @SerializedName("nextActiveDay")
    val nextActiveDay: String? = null,

    @SerializedName("previousActiveDay")
    val previousActiveDay: String? = null
)
