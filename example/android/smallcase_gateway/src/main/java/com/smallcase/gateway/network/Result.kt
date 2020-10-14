package com.smallcase.gateway.network

/**
 * Wrapper for handling Rest calls with Coroutines adapter
 */
sealed class Result<out T: Any> {
    data class Success<out T : Any>(val data: T) : Result<T>()
    data class Error(val throwable: Throwable ,val code:Int) : Result<Nothing>()
}

/**
 * Success callback for wrapper
 */

inline fun <T : Any> Result<T>.onSuccess(action: (T) -> Unit): Result<T> {
    if (this is Result.Success) action(data)

    return this
}


/**
 * Failure callback for wrapper
 */

inline fun <T : Any> Result<T>.onError(action: (Throwable,Int) -> Unit) {
    if (this is Result.Error ) action(throwable,code)

}


/**
 * Wrapper for passing Data from viewModel to Ui
 */

data class Resource<out T>(val status: Status, val data: T?, val error:String?) {
    companion object {
        fun <T> success(data: T): Resource<T> {
            return Resource(Status.SUCCESS, data, null)
        }

        fun <T> error(error:String): Resource<T> {
            return Resource(Status.ERROR, null, error )
        }
    }
}

enum class Status {
    SUCCESS,
    ERROR
}

