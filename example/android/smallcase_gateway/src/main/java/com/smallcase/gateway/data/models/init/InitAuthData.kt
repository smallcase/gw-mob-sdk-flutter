package com.smallcase.gateway.data.models.init

import com.google.gson.annotations.SerializedName
import com.smallcase.gateway.data.models.UserDataDTO

data class InitAuthData(

    @SerializedName("csrf")
    val csrf: String? = null,

    @SerializedName("gatewayToken")
    val gatewayToken: String? = null,

    @SerializedName("status")
    val status: String? = null,

    @SerializedName("userData")
    val userData: UserDataDTO? = null,

    @SerializedName("displayName")
    val displayName: String? = null,

    @SerializedName("defaultSCName")
    val defaultSCName: String? = null,

    @SerializedName("smallcaseAuthToken")
    val smallcaseAuthToken: String? = null,

    @SerializedName("allowedBrokers")
    val allowedBrokers:HashMap<String,List<String>>? = null
)
