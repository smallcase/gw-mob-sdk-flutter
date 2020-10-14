package com.smallcase.gateway.base.exceptions

import java.lang.Exception

class GatewayAlreadyConnectedException : Exception() {
    override val message: String?
        get() = "Gateway SDK is already initialisedt"
}
