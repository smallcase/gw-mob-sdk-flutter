package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class BaseReponseDataModel<T>(


    @SerializedName("success")
    val success: Boolean,
    @SerializedName("data")
    val data: T?,
    @SerializedName("errors")
    val error: List<String>? = null
)
