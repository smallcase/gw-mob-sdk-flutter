package com.smallcase.gateway.data.listeners

import com.smallcase.gateway.data.models.TransactionResult

/**
 *Wrapper for transaction related communication between consumer and the sdk
 **/
interface TransactionResponseListener {
    fun onSuccess(transactionResult: TransactionResult)
    fun onError(errorCode: Int, errorMessage: String)
}
