package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class OrderConfig(

    @SerializedName("type")
    val type: String? = null,

    @SerializedName("scid")
    val scid: String? = null,

    @SerializedName("name")
    val name: String? = null,

    @SerializedName("batchId")
    val batchId: String? = null
)
