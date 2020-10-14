package com.smallcase.gateway.base.exceptions

import java.lang.Exception

class UserNotConnectedException : Exception() {
    override val message: String?
        get() = "User is not connected, please call init() first"
}
