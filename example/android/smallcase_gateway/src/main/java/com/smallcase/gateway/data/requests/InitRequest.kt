package com.smallcase.gateway.data.requests

import com.google.gson.annotations.SerializedName

/**
 *Wrapper for init parameters required for initialising the SDK
 **/
class InitRequest(

    @SerializedName("sdkToken")
    var sdkToken: String = ""
)
