
package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class SipDTO(

    @SerializedName("iscid")
    val iscid: String? = null,

    @SerializedName("scid")
    val scid: String? = null,

    @SerializedName("name")
    val name: String? = null,

    @SerializedName("source")
    val source: String? = null,

    @SerializedName("frequency")
    val frequency: String? = null,

    @SerializedName("amount")
    val amount: Double? = null,

    @SerializedName("scheduledDate")
    val scheduledDate: String? = null
)
