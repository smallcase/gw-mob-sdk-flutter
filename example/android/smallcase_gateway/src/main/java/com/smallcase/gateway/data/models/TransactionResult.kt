package com.smallcase.gateway.data.models

import com.smallcase.gateway.portal.SmallcaseGatewaySdk

data class TransactionResult(
    val success: Boolean,
    val transaction: SmallcaseGatewaySdk.Result,
    val data: String?,
    val errorCode: Int?,
    val error: String?
)
