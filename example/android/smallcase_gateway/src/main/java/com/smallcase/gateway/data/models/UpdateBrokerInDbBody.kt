package com.smallcase.gateway.data.models

data class UpdateBrokerInDbBody(
    val transactionId: String,
    val update: Update
)