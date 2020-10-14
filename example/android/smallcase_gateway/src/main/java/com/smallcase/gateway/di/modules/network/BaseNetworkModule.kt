package com.smallcase.gateway.di.modules.network

import android.util.Log
import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.moczul.ok2curl.CurlInterceptor
import com.moczul.ok2curl.logger.Loggable
import com.smallcase.gateway.base.Session.SessionManager
import dagger.Module
import dagger.Provides
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Response
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
class BaseNetworkModule {

    @Provides
    @Singleton
    fun provideLoggingInterceptor():HttpLoggingInterceptor = HttpLoggingInterceptor().also { it.level = HttpLoggingInterceptor.Level.BODY }

    @Provides
    @Singleton
    fun provideCoroutineCallAdapter():CoroutineCallAdapterFactory = CoroutineCallAdapterFactory()

    @Provides
    @Singleton
    fun provideLoggable():Loggable = Loggable { Log.e("CURL_REQUEST", it) }

    @Provides
    @Singleton
    fun provideCurlInterceptor(loggable: Loggable):CurlInterceptor =  CurlInterceptor(loggable)

    @Provides
    @Singleton
    fun provideGsonConverterFactory():GsonConverterFactory = GsonConverterFactory.create()

    @Provides
    @Singleton
    fun provideSessionManager():SessionManager= SessionManager()







}