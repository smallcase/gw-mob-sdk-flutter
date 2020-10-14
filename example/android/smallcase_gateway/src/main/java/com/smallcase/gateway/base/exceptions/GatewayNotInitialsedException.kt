package com.smallcase.gateway.base.exceptions

import java.lang.Exception

class GatewayNotInitialsedException : Exception() {
    override val message: String?
        get() = "Gateway SDK not initialised, please call init() first"
}
