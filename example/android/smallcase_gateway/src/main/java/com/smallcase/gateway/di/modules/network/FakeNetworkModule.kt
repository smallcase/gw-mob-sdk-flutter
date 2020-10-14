package com.smallcase.gateway.di.modules.network

import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.moczul.ok2curl.CurlInterceptor
import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.network.apiInterface.FakeApiService
import com.smallcase.gateway.network.interceptor.FakeInterceptor
import dagger.Module
import dagger.Provides
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Named
import javax.inject.Singleton

@Module
class FakeNetworkModule {


    @Provides
    @Singleton
    fun provideFakeInterceptor(): FakeInterceptor =
        FakeInterceptor()



    @Provides
    @Singleton
    @Named("fake_http_client")
    fun provideGatewayHttpClient(interceptor: FakeInterceptor
                                 , curlInterceptor: CurlInterceptor,
                                 httpLoggingInterceptor: HttpLoggingInterceptor
    ): OkHttpClient = OkHttpClient().newBuilder().apply {
        addInterceptor(interceptor)
        if (BuildConfig.BUILD_TYPE.contains("debug", true) ||
            BuildConfig.BUILD_TYPE.contains("staging", true)) {
            addInterceptor(httpLoggingInterceptor)
            addInterceptor(curlInterceptor)
        }
    }.build()

    @Provides
    @Singleton
    @Named("fake_retrofit")
    fun provideGatewayRetrofit(@Named("fake_http_client") okHttpClient: OkHttpClient,
                               gsonConverterFactory: GsonConverterFactory,
                               coroutineCallAdapterFactory: CoroutineCallAdapterFactory
    ) =
        Retrofit.Builder()
            .client(okHttpClient)
            .baseUrl("https://config.smallcase.com/")
            .addConverterFactory(gsonConverterFactory)
            .addCallAdapterFactory(coroutineCallAdapterFactory)
            .build()



    @Provides
    @Singleton
    fun provideGatewayApiService(@Named("fake_retrofit") retrofit : Retrofit): FakeApiService = retrofit.create(
        FakeApiService::class.java)




}