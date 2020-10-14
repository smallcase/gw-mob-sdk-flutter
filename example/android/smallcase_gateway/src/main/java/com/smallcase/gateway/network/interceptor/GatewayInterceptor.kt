package com.smallcase.gateway.network.interceptor

import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.base.Session.SessionManager
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class GatewayInterceptor @Inject constructor(val sessionManager: SessionManager): Interceptor
{
    @Volatile
    private var host:String =getHost()

    fun setHost()
    {
        this.host =getHost()
    }

    private fun getHost():String{
      return  when {
            sessionManager.BUILD_VARIANT.contains(
                SessionManager.DEVELOPMENT,
                true
            ) -> Global.DEV_SMALLCASE_GATEWAY_BASE_URL
            sessionManager.BUILD_VARIANT.contains(
                SessionManager.STAGING,
                true
            ) -> Global.STAGING_SMALLCASE_GATEWAY_BASE_URL
            else -> Global.PROD_SMALLCASE_GATEWAY_BASE_URL
        }.replace("https://", "")
    }



    override fun intercept(chain: Interceptor.Chain): Response {

        return chain.proceed(chain.request()
            .newBuilder()
            .url(chain.request().url().newBuilder().host(host).build())
            .addHeader("x-sc-csrf", sessionManager.csrf)
            .addHeader("x-sc-gateway", sessionManager.gatewayToken)
            .build())
    }



}