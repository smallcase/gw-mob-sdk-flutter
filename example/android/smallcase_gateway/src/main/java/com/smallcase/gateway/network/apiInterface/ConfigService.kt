package com.smallcase.gateway.network.apiInterface

import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.UiConfigItem
import com.smallcase.gateway.data.models.tweetConfig.TweetConfigDTO
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path

interface ConfigService {

    @GET("brokerconfig/{buildVariant}/brokerConfig.json")
    fun getBrokerConfigs(
        @Path("buildVariant") buildType: String
    ): Call<List<BrokerConfig>>

    @GET("gateway/copyConfig/{buildVariant}/copyConfig.json")
    fun getUiConfig(@Path("buildVariant") buildType: String): Call<HashMap<String, UiConfigItem>>

    @GET("brokerconfig/{buildVariant}/tweetConfig.json")
    fun getTweetConfig(@Path("buildVariant") buildType: String):Call<TweetConfigDTO>

}
