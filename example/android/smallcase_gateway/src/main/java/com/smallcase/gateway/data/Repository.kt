package com.smallcase.gateway.data

import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.data.models.init.InitAuthData
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.network.Result


interface Repository {


    suspend fun initSession(
        initRequest:InitRequest
    ):Result<BaseReponseDataModel<InitAuthData>>


    suspend fun getSmallcases(sortBy:String?, sortOrder:Int?):Result<SmallcaseGatewayDataResponse>



    suspend fun getProfileForSmallcase(scid:String):Result<SmallcaseGatewayDataResponse>



    suspend fun getNewsOfSmallcaseByScid(scid: String,count:Int?,offset: Int?):Result<SmallcaseGatewayDataResponse>

    suspend fun getNewsOfSmallcaseByIscid(iScid: String,count: Int?,offset: Int?):Result<SmallcaseGatewayDataResponse>


    suspend fun getUserInvestments():Result<SmallcaseGatewayDataResponse>



    suspend fun getUserInvestmentsDetails(
        iScid: String
    ):Result<SmallcaseGatewayDataResponse>



    suspend fun getExitedSmallcase():Result<SmallcaseGatewayDataResponse>



    suspend fun getCharts(
        scid: String,
        base: Int,
        benchmarkId: String,
        benchmarkType: String,
        duration: String?
    ):Result<SmallcaseGatewayDataResponse>



    suspend fun getTransactionPoolingStatus(
        transitionId: String
    ):Result<BaseReponseDataModel<TransactionPollStatusResponse>>



    suspend fun fetchOrderDetails(batchId:String):Result<BaseReponseDataModel<OrderDetails>>



    suspend fun getBrokerRedirectParams(
        urlParam: String,
        broker: String
    ):Result<BaseReponseDataModel<BrokerRedirectParams>>


    suspend fun checkIfMarkertIsOpen(
        broker:String
    ):Result<BaseReponseDataModel<MarketStatusCheck>>

    suspend fun updateBrokerInDb(
        updateBrokerInDbBody: UpdateBrokerInDbBody
    ):Result<Any>

    suspend fun updateDeviceTypeInDb(
        updateDeviceTypeBody: UpdateDeviceTypeBody
    ):Result<Any>

    suspend fun updateConsentInDb(
        updateConsent: UpdateConsent
    ):Result<Any>


    suspend fun markTransactionAsErrored(
        transactionId: String,
        errorMessage:String?,
        errorCode: Int?
    ):Result<BaseReponseDataModel<Boolean>>



    suspend fun markTransactionAsCancelled(
        transactionId: String
    ):Result<BaseReponseDataModel<Boolean>>
    fun getBuildType(): String
    fun setBuildType(newBuildType: String)
    fun getSmallcaseAuthToken(): String
    fun setSmallcaseAuthToken(newSmallcaseAuthToken: String)
    fun getTargetBrokerDisplayName(): String?
    fun setTargetBroker(newTargetBroker: String)
    fun getTargetDistributor(): String
    fun setTargetDistributor(newTargetDistributor: String)
    fun getCurrentGateway(): String
    fun setCurrentGateway(newGateway: String)
    fun getTransactionId(): String
    fun setTransactionId(newTransactionId: String)
    fun isConnected(): Boolean
    fun setIsConnected(connectionStatus: Boolean)
    fun isUserConnected(): Boolean
    fun setInternalErrorOccured()
    fun isLeprechaunConnected(): Boolean
    fun setIsLeprechaunConnected(leprechaunStatus: Boolean)
    fun isAmoModeActive(): Boolean
    fun setIsAmoModeActive(amoStatus: Boolean)
    fun getConnectedUserData(): UserDataDTO?
    fun setConnectedUser(newConnectedUser: UserDataDTO?)
    fun getPreRequestedBrokers(): List<String>?
    fun setPreRequestedBrokers(newPreRequestedBrokers: List<String>?)

    fun setTargetBroker(newTargetBroker: BrokerConfig)
    fun setTargetBrokerByName(newTargetBrokerName: String)
    fun getTargetBroker(): BrokerConfig?

    fun setSmallcaseName(newSmallcase: String)
    fun getSmallcaseName(): String

    fun setConfigEnvironment(environment: Environment, setupListener: SmallcaseGatewayListeners)
    fun setTransactionResultListener(newTransactionResponseListener: TransactionResponseListener)
    fun setTransactionResult(newTransactionResult: TransactionResult)
    fun setTransactionFailed(errorCode: Int, errorMessage: String)
    fun setCurrentIntent(intent:String)
    fun getCurrentIntent():String
    fun getAllowedBroker():HashMap<String,List<String>>
}

interface SmallcaseGatewayListeners {
    fun onGatewaySetupSuccessfull()
    fun onGatewaySetupFailed(error: String)
}
