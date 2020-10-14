package com.smallcase.gateway.base.network

/*
* Used internally inside the SDK, as a wrapper listener for response from other components*/
interface RetrofitRxCallbackInterface<T> {

    fun onComplete(result: T)

    fun onError(errorCode: Int, error: String)
}
