package com.smallcase.gateway.screens.base

import android.util.Log
import com.smallcase.gateway.network.Result
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.IOException
import java.lang.Exception
import java.net.SocketTimeoutException
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

open class BaseRepo {

    suspend fun <T : Any> safeApiCall(call: suspend () -> Response<T>,errorMessage: String): Result<T> {
        return safeApiResult(call, errorMessage)
    }


    private suspend fun <T: Any> safeApiResult(call: suspend ()-> Response<T>, errorMessage: String) : Result<T>{
        return try {
            val response = call.invoke()
            response.body().let { bdy->
                if (bdy!=null) Result.Success(bdy)
                else Result.Error(Exception(errorMessage),response.code())

            }

        }catch (e: Exception) {
            return Result.Error(Exception(errorMessage),-1)
        }
    }

    suspend fun <T : Any> Call<T>.getResult(): Result<T> = suspendCoroutine {

        this.enqueue(object : Callback<T> {
            override fun onFailure(p0: Call<T>, p1: Throwable) {
                it.resume(Result.Error(p1,-1))
            }

            override fun onResponse(p0: Call<T>, response: Response<T>) {
                response.body()?.let { body ->
                    it.resume(Result.Success(body))
                } ?:
                it.resume(Result.Error(Throwable(),response.code()))
            }
        })

    }

}