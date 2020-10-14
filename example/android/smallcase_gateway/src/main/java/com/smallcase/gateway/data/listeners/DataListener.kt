package com.smallcase.gateway.data.listeners

/**
 *Wrapper for two way communication between consumer and the sdk
 **/
interface DataListener<T> {
    fun onSuccess(response: T)
    fun onFailure(errorCode: Int, errorMessage: String)
}
