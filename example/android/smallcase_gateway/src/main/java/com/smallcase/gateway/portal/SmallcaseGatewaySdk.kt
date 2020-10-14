package com.smallcase.gateway.portal

import android.app.Activity
import android.util.Log
//import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.base.network.RetrofitRxCallbackInterface
import com.smallcase.gateway.data.ApiFactory
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.enums.BuildTypes
import com.smallcase.gateway.network.onError
import com.smallcase.gateway.network.onSuccess
import com.smallcase.gateway.screens.connect.activity.ConnectActivity
import com.smallcase.gateway.screens.leadgen.activity.LeadGenActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.Dispatcher
import javax.inject.Inject

/**
 * {@link #init() init method}
 * <p>To initialse the gateway sdk call {@link #init() init method} to your app component
 *
 * <div class="special reference">
 * <h3>Developer Guides</h3>
 *
 * <p>For information about how to use the action bar, including how to add action items, navigation
 * modes and more, read the <a href="{@docRoot}guide/topics/ui/actionbar.html">Action
 * Bar</a> API guide.</p>
 * </div>
 *
 *
 * <p>
 * SmallcaseGatewaySdk page for fetching smallcase related gateway_loader
 * Guest connect allows following calls
 *
 *
 * Rest of the following calls mandates connected user i.e user account should be connected to a broker
 *
 *
 * Data is provided back to listener component through DataListener<T> interface
 *
 * </p>
 */

object SmallcaseGatewaySdk : SmallcaseGatewayContracts {


    private var isInitRunning = false
    private var isTransacationRunning = false

    enum class Result {
        CONNECT,
        TRANSACTION,
        HOLDING_IMPORT,
        ERROR
    }

    fun getTransactionId():String = LibraryCore.getInstance().gateRepo.getTransactionId()

    fun getBrokerConfig():List<BrokerConfig> = LibraryCore.getInstance().configRepo.getBrokerConfig()

    fun getSmallcaseAuthToken():String
    {
       return LibraryCore.getInstance().gateRepo.getSmallcaseAuthToken()
    }

    fun setTransactionResult(newTransactionResult:TransactionResult){
        LibraryCore.getInstance().gateRepo.setTransactionResult(newTransactionResult)
    }

    fun getConnectedUserData():UserDataDTO?{
        return LibraryCore.getInstance().gateRepo.getConnectedUserData()
    }

    fun isUserConnected():Boolean{
        return LibraryCore.getInstance().gateRepo.isUserConnected()
    }

    override fun setConfigEnvironment(environment: Environment, smallcaseGatewayListeners: SmallcaseGatewayListeners) {
        LibraryCore.getInstance().gateRepo.setConfigEnvironment(environment,smallcaseGatewayListeners)

    }

    override fun init(
        authRequest: InitRequest,
        gatewayInitialisationListener: DataListener<InitialisationResponse>?
    ) {

        if (isInitRunning) {
            gatewayInitialisationListener?.onFailure(
                SdkConstants.ErrorCode.CHECK_VIOLETED, "Init process in already running," +
                        "please wait"
            )
        } else {
            isInitRunning = true
            //ApiFactory.repository.setGatewayToken(authRequest.sdkToken)
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.initSession(authRequest).also {
                     it.onSuccess {
                         withContext(Dispatchers.Main) {
                         Log.i("REPO_IMP", "response of init session is:-$it")

                         if (it.success) {
                             LibraryCore.getInstance().gateRepo.setConnectedUser(it.data?.userData)
                             LibraryCore.getInstance().sessionManager.csrf=it.data?.csrf ?: ""
                             LibraryCore.getInstance().sessionManager.gatewayToken = it.data?.gatewayToken ?: ""
                             LibraryCore.getInstance().gateRepo.setIsConnected(it.data?.status!!.contains("connected", true))
                             LibraryCore.getInstance().sessionManager.isConnected = true
                             LibraryCore.getInstance().gateRepo.setTargetDistributor(it.data.displayName ?: "")
                             it.data.allowedBrokers?.let {allowedBroker->
                                 LibraryCore.getInstance().sessionManager.allowedBrokers.clear()
                                 LibraryCore.getInstance().sessionManager.allowedBrokers.putAll(allowedBroker)
                             }
                             if (LibraryCore.getInstance().gateRepo.getConnectedUserData()?.broker != null) {
                                 val brokerName = LibraryCore.getInstance().gateRepo.getConnectedUserData()?.broker?.name ?: ""
                                 if (brokerName.contains("${Global.LEPRECHAUN}")) {
                                     LibraryCore.getInstance().gateRepo.setIsLeprechaunConnected(true)
                                 }
                                 LibraryCore.getInstance().gateRepo.setTargetBroker(
                                     brokerName.replace(
                                         "-${Global.LEPRECHAUN}",
                                         ""
                                     )
                                 )
                             }

                             val initResponse =
                                 InitialisationResponse(it.data.gatewayToken, it.data.csrf)
                             gatewayInitialisationListener?.onSuccess(initResponse)
                         } else {
                             gatewayInitialisationListener?.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                         }



                         }
                         isInitRunning = false
                     }

                    it.onError {_,_->
                        withContext(Dispatchers.Main){
                            isInitRunning = false
                            gatewayInitialisationListener?.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                        }

                    }
                }
            }

        }
    }

    override fun getSmallcases(
        sortBy: String?,
        sortOrder: Int?,
        smallcasesListener: DataListener<SmallcaseGatewayDataResponse>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            smallcasesListener.onFailure(
                SdkConstants.ErrorCode.CHECK_VIOLETED,
                "Gateway not initialised, please initialise SDK first"
            )
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getSmallcases(sortBy, sortOrder).also {
                    it.onSuccess {
                        withContext(Dispatchers.Main){
                            smallcasesListener.onSuccess(it)
                        }
                    }
                    it.onError {th,_->
                        withContext(Dispatchers.Main){
                            smallcasesListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                        }
                    }
                }
            }

        }
    }

    override fun getSmallcaseProfile(
        smallcaseId: String,
        smallcaseProfileListener: DataListener<SmallcaseGatewayDataResponse>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            smallcaseProfileListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getProfileForSmallcase(smallcaseId).also {
                    it.onSuccess {
                        withContext(Dispatchers.Main){
                            smallcaseProfileListener.onSuccess(it)
                        }
                    }
                    it.onError {th,_->
                        withContext(Dispatchers.Main){
                            smallcaseProfileListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                        }
                    }
                }
            }

        }
    }

    override fun getSmallcaseNews(
        scid: String?,
        iScid: String?,
        count: Int?,
        offset: Int?,
        smallcaseNewsListener: DataListener<SmallcaseGatewayDataResponse>
    ) {

        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            smallcaseNewsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (scid == null && iScid == null) {
            smallcaseNewsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw InputMismatchException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                scid?.let {
                    LibraryCore.getInstance().gateRepo.getNewsOfSmallcaseByScid(it,count,offset).also {
                        withContext(Dispatchers.Main){
                            it.onSuccess { smallcaseNewsListener.onSuccess(it) }
                            it.onError {th,_-> smallcaseNewsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error) }
                        }

                    }
                }

                iScid?.let {
                    LibraryCore.getInstance().gateRepo.getNewsOfSmallcaseByIscid(it,count, offset).also {
                        withContext(Dispatchers.Main){
                            it.onSuccess { smallcaseNewsListener.onSuccess(it)}
                            it.onError {th,_-> smallcaseNewsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error) }
                        }

                    }
                }
            }

        }
    }

    override fun getUserInvestments(
        iScids: List<String>?,
        smallcaseNewsListener: DataListener<SmallcaseGatewayDataResponse>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            smallcaseNewsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (!LibraryCore.getInstance().gateRepo.isUserConnected()) {
            smallcaseNewsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw UserNotConnectedException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getUserInvestments().also {
                    withContext(Dispatchers.Main)
                    {
                        it.onSuccess { smallcaseNewsListener.onSuccess(it) }
                        it.onError {th,_-> smallcaseNewsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)   }
                    }
                }
            }
        }
    }

    override fun getHistorical(
        scId: String,
        benchmarkId: String,
        benchmarkType: String,
        duration: String?,
        base: Int,
        smallcaseChartsListener: DataListener<SmallcaseGatewayDataResponse>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            smallcaseChartsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (!LibraryCore.getInstance().gateRepo.isUserConnected()) {
            smallcaseChartsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw UserNotConnectedException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getCharts(scId,base, benchmarkId, benchmarkType, duration).also {
                    withContext(Dispatchers.Main){
                        it.onSuccess { smallcaseChartsListener.onSuccess(it) }
                        it.onError {th,_-> smallcaseChartsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error) }
                    }
                }
            }
        }
    }

    fun getOrderDetails(
        batchId: String,
        orderDetailsListener: DataListener<OrderDetails>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            orderDetailsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (!LibraryCore.getInstance().gateRepo.isUserConnected()) {
            orderDetailsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw UserNotConnectedException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.fetchOrderDetails(batchId).also {
                    withContext(Dispatchers.Main){
                        it.onSuccess { orderDetailsListener.onSuccess(it.data!!) }

                        it.onError {th,_-> orderDetailsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error) }
                    }

                }
            }
        }
    }

    /**
     * Get Transaction status to identify the intent and purpose of the request and then
     * switch cases accordingly
     * If the user is already connected then return the stored user as success response directly in case of Connect intent
     * */

    override fun triggerTransaction(
        activity: Activity,
        transactionId: String,
        transactionResponseListener: TransactionResponseListener
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            transactionResponseListener.onError(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )
        } else if (!isTransacationRunning) {
            isTransacationRunning = true

            if (!LibraryCore.getInstance().gateRepo.isConnected()) {

                isTransacationRunning = false
                transactionResponseListener.onError(
                    SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                    SdkConstants.ErrorMap.SDK_INIT_ERROR.error
                )
            } else {

                LibraryCore.getInstance().gateRepo.setTransactionId(transactionId)
                LibraryCore.getInstance().gateRepo.setTransactionResultListener(transactionResponseListener)

                CoroutineScope(Dispatchers.IO).launch {
                    LibraryCore.getInstance().gateRepo.getTransactionPoolingStatus(LibraryCore.getInstance().gateRepo.getTransactionId()).also {
                        withContext(Dispatchers.Main){
                           it.onSuccess {
                               isTransacationRunning = false

                               if (it.data!!.transaction.intent == SdkConstants.TransactionIntent.TRANSACTION) {
                                   ConnectActivity.start(activity)
                               } else if (it.data.transaction.intent == SdkConstants.TransactionIntent.CONNECT) {

                                   if (LibraryCore.getInstance().gateRepo.isUserConnected()) {
                                       launchConnectedUser()
                                   } else {
                                       ConnectActivity.start(activity)
                                   }
                               } else if (it.data.transaction.intent == SdkConstants.TransactionIntent.HOLDINGS_IMPORT) {
                                   ConnectActivity.start(activity)
                               } else {
                                   LibraryCore.getInstance().gateRepo.setInternalErrorOccured()
                               }
                           }

                            it.onError {_,code->
                                isTransacationRunning = false
                                if (code == 400){
                                    transactionResponseListener.onError(
                                        SdkConstants.ErrorMap.INVALID_TRANSACTION_ID.code,
                                        SdkConstants.ErrorMap.INVALID_TRANSACTION_ID.error
                                    )
                                } else
                                {
                                    LibraryCore.getInstance().gateRepo.setInternalErrorOccured()
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    override fun triggerLeadGen(
        activity: Activity,
        params:HashMap<String,String>?
    ) {
        if (LibraryCore.getInstance().gateRepo.isConnected()) {
            LeadGenActivity.openLeadGen(activity,params)
        }

    }

    private fun checkIfMarketIsOpen(broker: String) {
       /* // if the market or amo is open then proceed with transaction else pass back market is closed error
        LibraryCore.getInstance().daggerAppComponent.getConfigRepo().checkIfMarketIsOpen(
            broker,
            object : RetrofitRxCallbackInterface<BaseReponseDataModel<MarketStatusCheck>> {
                override fun onComplete(result: BaseReponseDataModel<MarketStatusCheck>) {
                    if (result.data!!.marketOpen!! || result.data.amoActive!!) {
                    } else {
                        // throw an error saying market is not open currently
                    }
                }

                override fun onError(errorCode: Int, error: String) {
                }
            })*/
    }

    private fun launchConnectedUser() {
        LibraryCore.getInstance().gateRepo.setTransactionResult(
            TransactionResult(
                true, Result.CONNECT,
                LibraryCore.getInstance().gateRepo.getSmallcaseAuthToken(), null, null
            )
        )
    }

    override fun getExitedSmallcases(exitedSmallcasesListener: DataListener<SmallcaseGatewayDataResponse>) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            exitedSmallcasesListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (!LibraryCore.getInstance().gateRepo.isUserConnected()) {
            exitedSmallcasesListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw UserNotConnectedException()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getExitedSmallcase().also {
                    it.onSuccess {
                        withContext(Dispatchers.Main)
                        {
                            exitedSmallcasesListener.onSuccess(it)
                        }
                    }
                    it.onError {th,_->
                        withContext(Dispatchers.Main)
                        {
                            exitedSmallcasesListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                        }
                    }
                }
            }
        }
    }

    override fun getUserInvestmentDetails(
        iScid: String,
        userInvestmentDetailsListener: DataListener<SmallcaseGatewayDataResponse>
    ) {
        if (!LibraryCore.getInstance().gateRepo.isConnected()) {
            userInvestmentDetailsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw GatewayNotInitialsedException()
        } else if (!LibraryCore.getInstance().gateRepo.isUserConnected()) {
            userInvestmentDetailsListener.onFailure(
                SdkConstants.ErrorMap.SDK_INIT_ERROR.code,
                SdkConstants.ErrorMap.SDK_INIT_ERROR.error
            )

            // throw UserNotConnectedException()
        } else {

            CoroutineScope(Dispatchers.IO).launch {
                LibraryCore.getInstance().gateRepo.getUserInvestmentsDetails(iScid).also {
                    it.onSuccess {
                        withContext(Dispatchers.Main)
                        {
                            if (it.data != null) {
                                userInvestmentDetailsListener.onSuccess(it)
                            } else {
                                LibraryCore.getInstance().gateRepo.setInternalErrorOccured()
                            }
                        }
                    }
                    it.onError {th,_->
                        withContext(Dispatchers.Main)
                        {
                            userInvestmentDetailsListener.onFailure(SdkConstants.ErrorMap.API_ERROR.code, SdkConstants.ErrorMap.API_ERROR.error)
                        }
                    }
                }
            }


        }
    }
}
