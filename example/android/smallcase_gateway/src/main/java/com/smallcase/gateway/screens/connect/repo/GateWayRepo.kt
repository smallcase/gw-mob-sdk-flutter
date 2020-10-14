package com.smallcase.gateway.screens.connect.repo

import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.*
import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.data.models.init.InitAuthData
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.data.requests.MarkTranxAsErroredRequest
import com.smallcase.gateway.network.interceptor.GatewayInterceptor
import com.smallcase.gateway.network.Result
import com.smallcase.gateway.network.apiInterface.FakeApiService
import com.smallcase.gateway.network.apiInterface.GatewayApiService
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.base.BaseRepo
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class GateWayRepo @Inject constructor(private val gatewayApiService: GatewayApiService,private val sessionManager: SessionManager,private val configRepository: ConfigRepository,private val  interceptor: GatewayInterceptor):BaseRepo(),Repository{




    private var preRequestedBrokers: List<String>? = null
    /*private var csrf: String = ""
    private var gatewayToken = ""*/
    private var transactionId = ""
    private var isUserConnected = false
    private var isLeprechaunModeActive = false
    private var isAmoModeActive = false
    private var connectUserData: UserDataDTO? = null
    private var targetBroker: BrokerConfig? = null
    private var targetDistributorName = ""

    private val GATEWAY_TYPE="SINGLE_SECURITY"

    private var transactionResponseListener: TransactionResponseListener? = null

    private lateinit var localEnvironment: Environment



    override suspend fun initSession(initRequest: InitRequest): Result<BaseReponseDataModel<InitAuthData>> {
        sessionManager.CURRENT_SMALLCASE_AUTH_TOKEN = initRequest.sdkToken

       return gatewayApiService.initSession(sessionManager.CURRENT_GATEWAY,initRequest).getResult()
    }



    override suspend fun getSmallcases(
        sortBy: String?,
        sortOrder: Int?
    ): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getSmallcases(sessionManager.CURRENT_GATEWAY,sortBy, sortOrder).getResult()




    override suspend fun getProfileForSmallcase(scid: String): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getSmallcaseProfile(sessionManager.CURRENT_GATEWAY,scid).getResult()

    override suspend fun updateBrokerInDb(updateBrokerInDbBody: UpdateBrokerInDbBody): Result<Any> = gatewayApiService.updateBrokerInDb(sessionManager.CURRENT_GATEWAY,updateBrokerInDbBody).getResult()

    override suspend fun updateDeviceTypeInDb(updateDeviceTypeBody: UpdateDeviceTypeBody): Result<Any> = gatewayApiService.updateDeviceType(sessionManager.CURRENT_GATEWAY,updateDeviceTypeBody).getResult()

    override suspend fun updateConsentInDb(updateConsent: UpdateConsent): Result<Any> = gatewayApiService.updateConsent(sessionManager.CURRENT_GATEWAY,updateConsent).getResult()

    override suspend fun getNewsOfSmallcaseByScid(
        scid: String,
        count: Int?,
        offset: Int?
    ): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getSmallcaseNewsByScid(sessionManager.CURRENT_GATEWAY,scid,count,offset).getResult()

    override suspend fun getNewsOfSmallcaseByIscid(
        iScid: String,
        count: Int?,
        offset: Int?
    ): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getSmallcaseNewsByiScid(sessionManager.CURRENT_GATEWAY,iScid,count, offset).getResult()




    override suspend fun getUserInvestments(): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getUserInvestments(sessionManager.CURRENT_GATEWAY).getResult()



    override suspend fun getUserInvestmentsDetails(iScid: String): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getUserInvestmentsDetails(sessionManager.CURRENT_GATEWAY, listOf(iScid)).getResult()




    override suspend fun getExitedSmallcase(): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getExitedSmallcases(sessionManager.CURRENT_GATEWAY).getResult()




    override suspend fun getCharts(
        scid: String,
        base: Int,
        benchmarkId: String,
        benchmarkType: String,
        duration: String?
    ): Result<SmallcaseGatewayDataResponse> = gatewayApiService.getSmallcaseCharts(sessionManager.CURRENT_GATEWAY,
            scid,benchmarkId,benchmarkType,base,duration).getResult()




    override suspend fun getTransactionPoolingStatus(transitionId: String) = gatewayApiService.getTransactionPollingResult(sessionManager.CURRENT_GATEWAY,transactionId).getResult()








    override suspend fun fetchOrderDetails(batchId: String): Result<BaseReponseDataModel<OrderDetails>> = gatewayApiService.getOrderDetails(sessionManager.CURRENT_GATEWAY,GATEWAY_TYPE,batchId).getResult()




    override suspend fun getBrokerRedirectParams(
        urlParam: String,
        broker: String
    ): Result<BaseReponseDataModel<BrokerRedirectParams>> = gatewayApiService.getBrokerRedirectParams(sessionManager.CURRENT_GATEWAY,urlParam,broker).getResult()




    override suspend fun checkIfMarkertIsOpen(broker: String): Result<BaseReponseDataModel<MarketStatusCheck>> = gatewayApiService.getMarketStatusChecked(sessionManager.CURRENT_GATEWAY,broker).getResult()




    override suspend fun markTransactionAsErrored(
        transactionId: String,
        errorMessage: String?,
        errorCode: Int?
    ): Result<BaseReponseDataModel<Boolean>> = gatewayApiService.markTranxAsErrored(sessionManager.CURRENT_GATEWAY, MarkTranxAsErroredRequest(transactionId, errorMessage, errorCode)).getResult()



    override suspend fun markTransactionAsCancelled(transactionId: String): Result<BaseReponseDataModel<Boolean>> =gatewayApiService.markTranxAsCancelled(sessionManager.CURRENT_GATEWAY, MarkTranxAsCancelledRequest(transactionId)).getResult()


    override fun getBuildType(): String = sessionManager.BUILD_VARIANT

    override fun setBuildType(newBuildType: String) {
        sessionManager.BUILD_VARIANT = newBuildType
    }

    override fun getSmallcaseAuthToken(): String = sessionManager.CURRENT_SMALLCASE_AUTH_TOKEN

    override fun setSmallcaseAuthToken(newSmallcaseAuthToken: String) {
       sessionManager.CURRENT_SMALLCASE_AUTH_TOKEN = newSmallcaseAuthToken
    }

    override fun getTargetBrokerDisplayName(): String? = targetBroker?.brokerDisplayName

    override fun setTargetBroker(newTargetBroker: String) {
        for (item in configRepository.getBrokerConfig()) {
            if (item.broker == newTargetBroker) {
                this.targetBroker = item
            }
        }
    }

    override fun setTargetBroker(newTargetBroker: BrokerConfig) {
        this.targetBroker = newTargetBroker
    }

    override fun getTargetDistributor(): String = targetDistributorName

    override fun setTargetDistributor(newTargetDistributor: String) {
        this.targetDistributorName = newTargetDistributor
    }

    override fun getCurrentGateway(): String = sessionManager.CURRENT_GATEWAY

    override fun setCurrentGateway(newGateway: String) {
        sessionManager.CURRENT_GATEWAY = newGateway
    }

    override fun getTransactionId(): String = transactionId

    override fun setTransactionId(newTransactionId: String) {
        this.transactionId = newTransactionId
    }

    override fun isConnected(): Boolean = sessionManager.isConnected

    override fun setIsConnected(connectionStatus: Boolean) {
        this.isUserConnected = connectionStatus
    }

    override fun isUserConnected(): Boolean = isUserConnected

    override fun setInternalErrorOccured() {
       setTransactionResult(
           TransactionResult(false,SmallcaseGatewaySdk.Result.ERROR,null,SdkConstants.ErrorMap.API_ERROR.code,SdkConstants.ErrorMap.API_ERROR.error)
       )
    }

    override fun isLeprechaunConnected(): Boolean = isLeprechaunModeActive

    override fun setIsLeprechaunConnected(leprechaunStatus: Boolean) {
        this.isLeprechaunModeActive = leprechaunStatus
    }

    override fun isAmoModeActive(): Boolean = isAmoModeActive

    override fun setIsAmoModeActive(amoStatus: Boolean) {
        this.isAmoModeActive = amoStatus
    }

//    override fun isAmoActive(): Boolean = isAmoModeActive
//
//    override fun setIsAmoActive(amoStatus: Boolean) {
//        this.isAmoModeActive = amoStatus
//    }

    override fun getConnectedUserData(): UserDataDTO? = connectUserData

    override fun setConnectedUser(newConnectedUser: UserDataDTO?) {
        this.connectUserData = newConnectedUser
    }

    override fun getPreRequestedBrokers(): List<String>? = preRequestedBrokers

    override fun setPreRequestedBrokers(newPreRequestedBrokers: List<String>?) {
       this.preRequestedBrokers = newPreRequestedBrokers
    }

    override fun setTargetBrokerByName(newTargetBrokerName: String) {
        for (broker in configRepository.getBrokerConfig()) {
            if (broker.broker == newTargetBrokerName) {
                this.targetBroker = broker
                break
            }
        }
    }

    override fun getTargetBroker(): BrokerConfig? = targetBroker

    override fun setSmallcaseName(newSmallcase: String) {
        this.targetDistributorName = newSmallcase
    }

    override fun getSmallcaseName(): String {
        return targetDistributorName
    }

    override fun setConfigEnvironment(
        environment: Environment,
        setupListener: SmallcaseGatewayListeners
    ) {
        this.localEnvironment = environment
        sessionManager.BUILD_VARIANT = when (environment.buildType) {
            Environment.PROTOCOL.PRODUCTION -> {
                SessionManager.PRODUCTION
            }
            Environment.PROTOCOL.STAGING -> {
                SessionManager.STAGING
            }
            else -> {
                SessionManager.DEVELOPMENT
            }
        }
        interceptor.setHost()
        sessionManager.CURRENT_GATEWAY = environment.gateway
        this.isLeprechaunModeActive = environment.isLeprachaunActive
        this.preRequestedBrokers = environment.preProvidedBrokers
        this.isAmoModeActive = environment.isAmoEnabled
        sessionManager.isConnected = false

        configRepository.loadConfigData(sessionManager.BUILD_VARIANT, setupListener)
    }

    override fun setTransactionResultListener(newTransactionResponseListener: TransactionResponseListener) {
        this.transactionResponseListener = newTransactionResponseListener
    }

    override fun setTransactionResult(newTransactionResult: TransactionResult) {
        this.transactionResponseListener?.onSuccess(newTransactionResult)
        this.transactionResponseListener = null
    }

    override fun setTransactionFailed(errorCode: Int, errorMessage: String) {
        this.transactionResponseListener?.onError(errorCode, errorMessage)
        this.transactionResponseListener = null
    }

    override fun setCurrentIntent(intent: String) {
        this.sessionManager.currentIntent = intent
    }

    override fun getCurrentIntent(): String = this.sessionManager.currentIntent

    override fun getAllowedBroker(): HashMap<String, List<String>> {
        return sessionManager.allowedBrokers
    }


}