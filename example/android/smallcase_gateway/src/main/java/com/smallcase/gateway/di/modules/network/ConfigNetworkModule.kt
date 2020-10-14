package com.smallcase.gateway.di.modules.network

import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.moczul.ok2curl.CurlInterceptor
import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.data.ConfigRepositoryImp
import com.smallcase.gateway.network.apiInterface.ConfigService
import com.smallcase.gateway.network.apiInterface.FakeApiService
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
class ConfigNetworkModule{

    @Provides
    @Singleton
    @Named("config_interceptor")
    fun provideConfigInterceptor(sessionManager: SessionManager): Interceptor = Interceptor { chain ->
        chain.proceed(chain.request()
            .newBuilder()
            .addHeader("x-sc-csrf", sessionManager.csrf)
            .addHeader("x-sc-gateway", sessionManager.gatewayToken)
            .build())
    }

    @Provides
    @Singleton
    @Named("config_http_client")
    fun provideGatewayHttpClient(@Named("config_interceptor") interceptor: Interceptor
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
    @Named("config_retrofit")
    fun provideGatewayRetrofit(@Named("config_http_client") okHttpClient: OkHttpClient,
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
    fun provideGatewayApiService(@Named("config_retrofit") retrofit : Retrofit): ConfigService = retrofit.create(
        ConfigService::class.java)

    @Provides
    @Singleton
    fun provideConfigRepository(configService: ConfigService, sessionManager: SessionManager, gatewayApiService:GatewayApiService,fakeApiService: FakeApiService):ConfigRepository = ConfigRepositoryImp(configService,gatewayApiService,sessionManager,fakeApiService)




}