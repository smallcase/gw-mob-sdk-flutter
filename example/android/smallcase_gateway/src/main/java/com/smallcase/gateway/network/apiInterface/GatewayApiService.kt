package com.smallcase.gateway.network.apiInterface

import com.smallcase.gateway.data.UpdateDeviceTypeBody
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.data.models.init.InitAuthData
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.data.requests.MarkTranxAsErroredRequest
import retrofit2.Call
import retrofit2.http.*

interface GatewayApiService {
    @POST("gateway/{gateway}/initSession")
    fun initSession(
        @Path("gateway") gateway: String,
        @Body initRequest: InitRequest
    ):Call<BaseReponseDataModel<InitAuthData>>


    @GET("gateway/{gateway}/smallcases")
    fun getSmallcases(
        @Path("gateway") gateway: String,
        @Query("sortBy") sortBy: String?,
        @Query("sortOrder") sortOrder: Int?
    ):Call<SmallcaseGatewayDataResponse>


    @GET("gateway/{gateway}/smallcase")
    fun getSmallcaseProfile(
        @Path("gateway") gateway: String,
        @Query("scid") scId: String
    ):Call<SmallcaseGatewayDataResponse>


    @GET("gateway/{gateway}/smallcase/news")
    fun getSmallcaseNewsByScid(
        @Path("gateway") gateway: String,
        @Query("scid") scId: String?,
        @Query("count") count: Int?,
        @Query("offset") offset: Int?
    ):Call<SmallcaseGatewayDataResponse>

    @GET("gateway/{gateway}/smallcase/news")
    fun getSmallcaseNewsByiScid(
        @Path("gateway") gateway: String,
        @Query("iscid") iScId: String?,
        @Query("count") count: Int?,
        @Query("offset") offset: Int?
    ):Call<SmallcaseGatewayDataResponse>

    @GET("gateway/{gateway}/smallcase/chart")
    fun getSmallcaseCharts(
        @Path("gateway") gateway: String,
        @Query("scid") scId: String,
        @Query("benchmarkId") benchmarkId: String,
        @Query("benchmarkType") benchmarkType: String,
        @Query("base") base: Int,
        @Query("duration") duration: String?
    ):Call<SmallcaseGatewayDataResponse>

    @GET("gateway/{gateway}/user/investments")
    fun getUserInvestments(@Path("gateway") gateway: String):
            Call<SmallcaseGatewayDataResponse>

    @GET("gateway/{gateway}/user/investments")
    fun getUserInvestmentsDetails(
        @Path("gateway") gateway: String,
        @Query("iscids[]") iScids: List<String>
    ):Call<SmallcaseGatewayDataResponse>


    @GET("gateway/{gateway}/market/checkStatus")
    fun getMarketStatusChecked(
        @Path("gateway") gateway: String,
        @Header("x-sc-broker") broker: String
    ):Call<BaseReponseDataModel<MarketStatusCheck>>

    @GET("gateway/{gateway}/transaction")
    fun getTransactionPollingResult(
        @Path("gateway") gateway: String,
        @Query("transactionId") transactionId: String
    ):Call<BaseReponseDataModel<TransactionPollStatusResponse>>

    @GET("gateway/{gateway}/user/orders")
    fun getOrderDetails(
        @Path("gateway") gateway: String,
        @Query("gatewayType") gatewayType: String,
        @Query("batchId") batchId: String
    ):Call<BaseReponseDataModel<OrderDetails>>

    @GET("gateway/{gateway}/brokerRedirectParams")
    fun getBrokerRedirectParams(
        @Path("gateway") gateway: String,
        @Query("url") urlParams: String,
        @Query("broker") broker: String
    ):Call<BaseReponseDataModel<BrokerRedirectParams>>


    @GET("gateway/{gateway}/user/exitedSmallcases")
    fun getExitedSmallcases(
        @Path("gateway") gateway: String
    ):Call<SmallcaseGatewayDataResponse>

    @POST("gateway/{gateway}/transaction/markErrored")
    fun markTranxAsErrored(
        @Path("gateway") gateway: String,
        @Body markTransAsErroredRequest: MarkTranxAsErroredRequest
    ): Call<BaseReponseDataModel<Boolean>>


    @POST("gateway/{gateway}/transaction/markErrored")
    fun markTranxAsCancelled(
        @Path("gateway") gateway: String,
        @Body markTransAsCancelledRequest: MarkTranxAsCancelledRequest
    ): Call<BaseReponseDataModel<Boolean>>

    @POST("gateway/{gateway}/transaction/update")
    fun updateBrokerInDb(
        @Path("gateway") gateway: String,
        @Body updateBrokerInDbBody: UpdateBrokerInDbBody
    ):Call<Any>

    @POST("gateway/{gateway}/transaction/update")
    fun updateDeviceType(
        @Path("gateway") gateway: String,
        @Body updateDeviceTypeBody: UpdateDeviceTypeBody
    ):Call<Any>

    @GET("gateway/{gateway}/partnerConfig")
    fun getPartnerConfig(@Path("gateway") gateway: String):Call<HashMap<String, UiConfigItem>>

    @POST("gateway/{gateway}/transaction/update")
    fun updateConsent(
        @Path("gateway") gateway: String,
        @Body updateConsent: UpdateConsent
    ):Call<Any>
}