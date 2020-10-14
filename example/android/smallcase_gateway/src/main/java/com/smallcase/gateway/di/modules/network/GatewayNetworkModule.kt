package com.smallcase.gateway.di.modules.network

import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.moczul.ok2curl.CurlInterceptor
import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.Repository


import com.smallcase.gateway.network.interceptor.GatewayInterceptor
import com.smallcase.gateway.network.apiInterface.GatewayApiService
import dagger.Module
import dagger.Provides
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Named
import javax.inject.Singleton

@Module
class GatewayNetworkModule {


    @Provides
    @Singleton
    fun provideGatewayInterceptor(sessionManager:SessionManager): GatewayInterceptor =
        GatewayInterceptor(
            sessionManager
        )



    @Provides
    @Singleton
    @Named("gateway_http_client")
    fun provideGatewayHttpClient(interceptor: GatewayInterceptor
                                 ,curlInterceptor: CurlInterceptor,
                                 httpLoggingInterceptor: HttpLoggingInterceptor):OkHttpClient = OkHttpClient().newBuilder().apply {
        addInterceptor(interceptor)
        if (BuildConfig.BUILD_TYPE.contains("debug", true) ||
            BuildConfig.BUILD_TYPE.contains("staging", true)) {
            addInterceptor(httpLoggingInterceptor)
            addInterceptor(curlInterceptor)
        }
    }.build()

    @Provides
    @Singleton
    @Named("gateway_retrofit")
    fun provideGatewayRetrofit( @Named("gateway_http_client") okHttpClient:OkHttpClient,
                                gsonConverterFactory: GsonConverterFactory,
                                coroutineCallAdapterFactory: CoroutineCallAdapterFactory) =
        Retrofit.Builder()
            .client(okHttpClient)
            .baseUrl(Global.BASE_URL)
            .addConverterFactory(gsonConverterFactory)
            .addCallAdapterFactory(coroutineCallAdapterFactory)
            .build()


    @Provides
    @Singleton
    fun provideGatewayApiService(@Named("gateway_retrofit") retrofit :Retrofit): GatewayApiService = retrofit.create(
        GatewayApiService::class.java)




}