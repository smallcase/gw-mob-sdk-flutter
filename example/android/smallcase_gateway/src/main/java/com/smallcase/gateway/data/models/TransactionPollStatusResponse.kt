package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class TransactionPollStatusResponse (

    @SerializedName("transaction")
    val transaction: SmallcaseTransaction
)
