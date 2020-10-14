package com.smallcase.gateway.base.network

import com.smallcase.gateway.data.models.Result

/**
 * Wrap a suspending API [call] in try/catch. In case an exception is thrown, a [Result.Error] is
 * created based on the exception.
 */
//suspend fun <T : Any> safeApiCall(call: suspend () -> Result<T>, errorMessage: String): Result<T> {
  //  return try {
    //    call()
   // } catch (e: Exception) {
     //   Result.Error(Exception(errorMessage, e))
   // }
//}

// //TODO: Handle 401, 403 and other cases in the safeApiCall itself
// suspend fun <T : Any> safeApiRequest(call: suspend () -> Response<T>, errorMessage: String): Result<T> {
//    try {
//        val response = call()
//        return when {
//            response.isSuccessful && (response.body() != null) -> {
//                Result.Success(response.body())
//            }
//            response.code() == 401 -> {
//                Result.Success(response.body())
//            }
//            response.code() == 403 -> {
//                Result.Success(response.body())
//            }
//            else -> {
//                Result.Success(response.body())
//            }
//        }
//    } catch (e: Exception) {
//        return Result.Error(Exception(errorMessage, e))
//    }
// }
