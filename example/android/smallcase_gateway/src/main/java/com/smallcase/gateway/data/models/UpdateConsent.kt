package com.smallcase.gateway.data.models

data class UpdateConsent(
    val transactionId: String,
    val update: UpdateConsentInDb
)