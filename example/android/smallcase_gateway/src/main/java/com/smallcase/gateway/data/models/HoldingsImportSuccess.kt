package com.smallcase.gateway.data.models

data class HoldingsImportSuccess(
    val smallcaseAuthToken:String?,
    val success:Boolean?,
    val transactionId:String?
)