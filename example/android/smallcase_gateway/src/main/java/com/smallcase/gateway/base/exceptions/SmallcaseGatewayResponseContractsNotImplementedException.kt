package com.smallcase.gateway.base.exceptions

import java.lang.Exception

class SmallcaseGatewayResponseContractsNotImplementedException : Exception() {
    override val message: String?
        get() = "Please implement Smallcase gateway contracts in your source activity before making this request"
}
