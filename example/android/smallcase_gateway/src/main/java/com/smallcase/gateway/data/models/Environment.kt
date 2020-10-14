package com.smallcase.gateway.data.models

class Environment(
    val buildType: Environment.PROTOCOL,
    val gateway: String,
    val isLeprachaunActive: Boolean,
    val isAmoEnabled: Boolean,
    val preProvidedBrokers: List<String>
) {
    enum class PROTOCOL {
        PRODUCTION,
        DEVELOPMENT,
        STAGING,
    }
}
