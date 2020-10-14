package com.smallcase.gateway.network.apiInterface

import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.UiConfigItem
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path

interface FakeApiService {

    @GET("gateway/{gateway}/partnerConfig")
    fun getPartnerConfig(@Path("gateway") gateway: String): Call<HashMap<String, UiConfigItem>>

    @GET("brokerconfig/{buildVariant}/brokerConfig.json")
    fun getBrokerConfigs(
        @Path("buildVariant") buildType: String
    ): Call<List<BrokerConfig>>
}