package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class FixDTO(

    @SerializedName("hidden")
    val hidden: Boolean? = null,

    @SerializedName("iscid")
    val iscid: String? = null,

    @SerializedName("date")
    val date: String? = null,

    @SerializedName("name")
    val name: String? = null,

    @SerializedName("batchId")
    val batchId: String? = null,

    @SerializedName("scid")
    val scid: String? = null,

    @SerializedName("source")
    val source: String? = null,

    @SerializedName("filled")
    val filled: Int? = null,

    @SerializedName("quantity")
    val quantity: Int? = null,

    @SerializedName("originalLabel")
    val originalLabel: String? = null
)
