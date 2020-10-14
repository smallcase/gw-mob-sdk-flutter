package com.smallcase.gateway.data

object SdkConstants {

    object TransactionIntent {
        const val CONNECT = "CONNECT"
        const val TRANSACTION = "TRANSACTION"
        const val HOLDINGS_IMPORT = "HOLDINGS_IMPORT"
    }

    object AllowedBrokers {
        const val SST = "sst"
        const val HOLDINGS_IMPORT = "holdingsImport"
        const val CONNECT = "connect"
    }

    object CompletionStatus {
        const val COMPLETED = "COMPLETED"
        const val ERRORED = "ERRORED"
        const val EXPIRED = "EXPIRED"
        const val INITIALISED = "INITIALIZED"
        const val USED = "USED"
        const val CANCELLED = "CANCELLED"
        const val PROCESSING = "PROCESSING"
        const val PENDING = "PENDING"
        const val USER_MISMATCH = "user_mismatch"
        const val API_ERROR = "internal_error"
        const val USER_CANCELLED = "user_cancelled"
        const val CONSENT_DENIED = "consent_denied"
        const val INSUFFICIENT_HOLDINGS = "insufficient_holdings"
        const val TRX_ID_EXPIRED = "transaction_expired"
        const val HOLDING_IMPORT_ERROR = "holdings_import_error"
        const val MARKET_CLOSED_ERROR = "market_closed"
        const val ORDER_IN_QUEUE = "order_in_queue"
    }

    object UniqueErrorCases {
        const val LOGIN_FAILED = "loginFailed"
        const val USER_ABONDEND_FLOW = "User abandoned the flow"
        const val NO_BROWSER_FOUND = "Please install Google Chrome to continue."
    }

    object ErrorCode {
        const val CHECK_VIOLETED = 4001
        const val DEFAULT_INTERNAL_ERROR = 4003
        const val MARKET_CLOSED_ERROR = 4004
        const val NO_BROWSER_FOUND_ERROR = 4005
        const val USER_MISMATCH = 1001
        const val API_ERROR = 2000
        const val USER_CANCELLED = 1002
        const val CONSENT_DENIED = 1003
        const val INSUFFICIENT_HOLDINGS = 1004
        const val TRX_ID_EXPIRED = 1005
        const val HOLDING_IMPORT_ERROR = 2001
    }

    enum class ErrorMap(val code:Int,val error:String)
    {
        CLOSED_BROKER_CHOOSER(1010,"user_cancelled"),
        OTHER_BROKER(1006,"no_broker"),
        NO_BROKER_ERROR(1008,"no_broker"),
        SIGNUP_OTHER_BROKER(1007,"no_broker"),
        TRANSACTION_EXPIRED_BEFORE(3001,"transaction_expired"),
        CLOSED_CHROME_TAB_INITIALIZED(1011,"user_cancelled"),
        CLOSED_CHROME_TAB_USED(1012,"user_cancelled"),
        USER_CONSENT_DENIED(1013,"user_consent_denied"),//new
        MARKET_CLOSED_ERROR(4004,"market_closed"),
        USER_MISMATCH (1001,"user_mismatch"),
        API_ERROR(2000,"internal_error"),
        USER_CANCELLED(1002,"user_cancelled"),
        CONSENT_DENIED(1003,"consent_denied"),
        INSUFFICIENT_HOLDINGS(1004,"insufficient_holdings"),
        TRX_ID_EXPIRED(1005,"transaction_expired"),
        HOLDING_IMPORT_ERROR(2001,"holdings_import_error"),
        INVALID_TRANSACTION_ID(3002,"invalid_transactionId"),
        TRANSACTION_IN_PROCESS(3003,"transaction_in_process"),
        SDK_INIT_ERROR(3004,"init_sdk"),
        ORDER_IN_QUEUE(4005,"order_in_queue"),
        TIMED_OUT(4003,"timed_out"),

    }
}
