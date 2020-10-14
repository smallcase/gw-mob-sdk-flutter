package com.smallcase.gateway.base.Session

class Global {
    companion object{
        val DEFAULT_ERROR: String = "Something went wrong, please try again"
        val PROD_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi.smallcase.com"
         val DEV_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi-dev.smallcase.com"
         val STAGING_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi.stag.smallcase.com"
         var BASE_URL = PROD_SMALLCASE_GATEWAY_BASE_URL

        var API_FAILURE="Api Failure"
        val LEPRECHAUN = "leprechaun"

        val DEVICE_TYPE: String = "ANDROID"
        val COPY_CONFIG: String = "copyConfig"
    }
}