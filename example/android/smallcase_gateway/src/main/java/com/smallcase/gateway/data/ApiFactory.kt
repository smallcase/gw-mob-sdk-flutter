package com.smallcase.gateway.data

import android.util.Log
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.moczul.ok2curl.CurlInterceptor
import com.moczul.ok2curl.logger.Loggable
import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.base.Session.SessionManager
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

/**
 *Factory/ DI injector for all the dependencies required by the SDK
 **/
object ApiFactory {

   /* val DEFAULT_ERROR: String = "Something went wrong, please try again"
    private val PROD_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi.smallcase.com"
    private val DEV_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi-dev.smallcase.com"
    private val STAGING_SMALLCASE_GATEWAY_BASE_URL = "https://gatewayapi.stag.smallcase.com"
    private var BASE_URL = PROD_SMALLCASE_GATEWAY_BASE_URL

    val LEPRECHAUN = "leprechaun"
    val DEVICE_TYPE: String = "ANDROID"
    private val gson = Gson()

    private val smallcaseLoggingInterceptor by lazy { HttpLoggingInterceptor() }
    private val coroutineCallAdapterFactory by lazy { CoroutineCallAdapterFactory() }
    private val rxJava2CallAdapterFactory by lazy { RxJava2CallAdapterFactory.create() }
    private val sessionManger by lazy { SessionManager() }

    private val curlInterceptor by lazy {
        CurlInterceptor(
            Loggable {
                Log.i("CURL_REQUEST", it)
            }
        )
    }

    // Creating Auth Interceptor to add api_key query in front of all the requests.
    private val smallcaseInterceptor: Interceptor by lazy {
        Interceptor { chain ->

            val newUrl = chain.request().url().newBuilder()
                .host(getBaseUrl().replace("https://", ""))
                .build()

            val newRequest = chain.request()
                .newBuilder()
                .url(newUrl)
                .addHeader("x-sc-csrf", sessionManger.csrf)
                .addHeader("x-sc-gateway", sessionManger.gatewayToken)
                .build()
            chain.proceed(newRequest)
        }
    }

    // Creating Auth Interceptor to add api_key query in front of all the requests.
    private val smallcaseConfigInterceptor: Interceptor by lazy {
        Interceptor { chain ->

            val newRequest:Request = chain.request()
                .newBuilder()
                .addHeader("x-sc-csrf", sessionManger.csrf)
                .addHeader("x-sc-gateway", sessionManger.gatewayToken)
                .build()

            chain.proceed(newRequest)
        }
    }

    // OkhttpClient for building http request url
    private val smallcaseOkHttpClient: OkHttpClient by lazy {
        OkHttpClient().newBuilder().apply {
            addInterceptor(smallcaseInterceptor)
            if (BuildConfig.BUILD_TYPE.contains("debug", true) ||
                BuildConfig.BUILD_TYPE.contains("staging", true)) {
                addInterceptor(smallcaseLoggingInterceptor)
                addInterceptor(curlInterceptor)
            }
        }.build()
    }

    // OkhttpClient for building http request url
    private val smallcaseConfigOkHttpClient: OkHttpClient by lazy {
        OkHttpClient().newBuilder().apply {
            addInterceptor(smallcaseConfigInterceptor)
            if (BuildConfig.BUILD_TYPE.contains("debug", true) ||
                BuildConfig.BUILD_TYPE.contains("staging", true)) {
                addInterceptor(smallcaseLoggingInterceptor)
                addInterceptor(curlInterceptor)
            }
        }.build()
    }

    private val configGsonConverFactory by lazy {
        val gsonBuilder = GsonBuilder()
        // gsonBuilder.registerTypeAdapter(UiConfigItem::class.java, UiConfigParserAdapter(gson))
        GsonConverterFactory.create(gsonBuilder.create())
    }

    private val apiGsonConverterFactory by lazy {
        val gsonBuilder = GsonBuilder()
        // gsonBuilder.registerTypeAdapter(String::class.java,ResponseToSmallcaseGatewayDataResponseAdapter(gson))
        GsonConverterFactory.create(gsonBuilder.create())
    }

    val smallcaseApiService: SmallcaseApiService by lazy {
        retrofit().create(SmallcaseApiService::class.java)
    }
    val configApiService: ConfigService by lazy { retrofitForConfigs().create(ConfigService::class.java) }

    //val repository: Repository by lazy { RepositoryImp(smallcaseApiService, SessionManager()) }
    val configRepository: ConfigRepository by lazy { ConfigRepositoryImp(configApiService) }

    init {
        smallcaseLoggingInterceptor.level = HttpLoggingInterceptor.Level.BODY
    }

    private fun retrofit(): Retrofit = Retrofit.Builder()
        .client(smallcaseOkHttpClient)
        .baseUrl(BASE_URL)
        .addConverterFactory(apiGsonConverterFactory)
        .addCallAdapterFactory(coroutineCallAdapterFactory)
        .addCallAdapterFactory(rxJava2CallAdapterFactory)
        .build()

    private fun retrofitForConfigs(): Retrofit = Retrofit.Builder()
        .client(smallcaseConfigOkHttpClient)
        .baseUrl("https://config.smallcase.com/")
        // .addConverterFactory(MoshiConverterFactory.create())
        .addConverterFactory(configGsonConverFactory)
        .addCallAdapterFactory(coroutineCallAdapterFactory)
        .addCallAdapterFactory(rxJava2CallAdapterFactory)
        .build()

   *//* private fun getBaseUrl(): String {
        return when {
            repository.getBuildType().contains(
                "develop",
                true
            ) -> DEV_SMALLCASE_GATEWAY_BASE_URL
            repository.getBuildType().contains(
                "staging",
                true
            ) -> STAGING_SMALLCASE_GATEWAY_BASE_URL
            else -> PROD_SMALLCASE_GATEWAY_BASE_URL
        }
    }*/
}
