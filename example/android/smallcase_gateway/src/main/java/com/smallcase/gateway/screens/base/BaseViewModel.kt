package com.smallcase.gateway.screens.base

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.airbnb.lottie.LottieAnimationView
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.base.helpers.GatewayUtilHelper
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.data.UpdateDeviceType
import com.smallcase.gateway.data.UpdateDeviceTypeBody
import com.smallcase.gateway.data.models.*
import com.smallcase.gateway.network.Resource
import com.smallcase.gateway.network.onError
import com.smallcase.gateway.network.onSuccess
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

open class BaseViewModel(
    private val configRepository: ConfigRepository,
    private val gateWayRepo: GateWayRepo
) :ViewModel()
{

    /**
     * This is the job for all coroutines started by this ViewModel.
     * Cancelling this job will cancel all coroutines started by this ViewModel.
     */
    private val viewModelJob = SupervisorJob()

    /**
     * This is the main scope for all coroutines launched by ViewModel.
     * Since we pass viewModelJob, you can cancel all coroutines
     * launched by uiScope by calling viewModelJob.cancel()
     */
     val uiScope = CoroutineScope(Dispatchers.Main + viewModelJob)


    /**
     * Cancel all coroutines when the ViewModel is cleared
     */
    override fun onCleared() {
        super.onCleared()
        viewModelJob.cancel()
    }

    val uiConfigs
    get() = configRepository.getUiConfig()

    val isAmoEnabled
    get() = gateWayRepo.isAmoModeActive()

    val tweetConfigs
    get() = configRepository.getTweetConfig()

    val getGatewayAuthToken
        get() = gateWayRepo.getSmallcaseAuthToken()

    val transactionId
        get() = gateWayRepo.getTransactionId()

    val broker
        get() = gateWayRepo.getConnectedUserData()?.broker?.name

    val currentGateway
    get() = gateWayRepo.getCurrentGateway()

    val checkIfMarketIsOpenLiveData: LiveData<Resource<BaseReponseDataModel<MarketStatusCheck>>>
            by lazy { checkIfMarketIsOpenMutableLiveData }

    private val checkIfMarketIsOpenMutableLiveData: MutableLiveData<Resource<BaseReponseDataModel<MarketStatusCheck>>>
            by lazy { MutableLiveData<Resource<BaseReponseDataModel<MarketStatusCheck>>>() }

    val transactionPollingStatusLiveData: LiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> by lazy {
        transactionPollStatusMutableLiveData
    }

    private val transactionPollStatusMutableLiveData: MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>>
            by lazy { MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>>() }

    val markTransactionAsErroredLiveData:LiveData<Resource<BaseReponseDataModel<Boolean>>> by lazy { markTransactionAsErroredMutableliveData }


    private val markTransactionAsErroredMutableliveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<Boolean>>>()
    }



    fun getTransactionPoolingStatus(){
        uiScope.launch {
            gateWayRepo.getTransactionPoolingStatus(gateWayRepo.getTransactionId()).also { result ->
                result.onSuccess {
                    transactionPollStatusMutableLiveData.postValue(Resource.success(it)) }

                result.onError {th,_->
                    gateWayRepo.setInternalErrorOccured()
                    transactionPollStatusMutableLiveData.postValue(
                        Resource.error(
                            th.message ?: Global.API_FAILURE
                        )
                    )
                }

            }
        }
    }

    fun getMarketIsOpen(broker: String){

        val sanitizeBroker = if(gateWayRepo.isLeprechaunConnected() && !broker.contains("-leprechaun")) {
            "$broker-leprechaun"
        } else {
            broker
        }
        uiScope.launch {
            gateWayRepo.checkIfMarkertIsOpen(sanitizeBroker).also { result ->
                result.onSuccess { checkIfMarketIsOpenMutableLiveData.postValue(Resource.success(it)) }
                result.onError {th,_->
                    gateWayRepo.setInternalErrorOccured()
                    checkIfMarketIsOpenMutableLiveData.postValue(Resource.error(th.message ?: Global.API_FAILURE))
                }
            }
        }
    }

    fun setGatewayTransactionStatus(
        success: Boolean,
        type: SmallcaseGatewaySdk.Result,
        data: String?,
        errorCode: Int?,
        error: String?
    ) {
        gateWayRepo.setTransactionResult(
            TransactionResult(
                success, type,
                data, errorCode, error
            )
        )
    }

    fun processConfigBasedUiStringLocally(input: String) =
        GatewayUtilHelper.processConfigBasedUiStringLocally(input, gateWayRepo)

    fun processTwitterHandleText(text:String,twitterHandle:String):String = GatewayUtilHelper.processTwitterHandleText(text, twitterHandle)


    fun setLoaderLottie(view: LottieAnimationView)
    {
        GatewayUtilHelper.setLoaderLottie(view,gateWayRepo)
    }

    fun setInternalErrorOccured()
    {
        gateWayRepo.setInternalErrorOccured()
    }

    fun markTransactionAsErrored(errorMessage:String?,errorCode:Int?)
    {
        uiScope.launch {
            gateWayRepo.markTransactionAsErrored(transactionId,errorMessage, errorCode).also { result ->
                result.onSuccess { response -> markTransactionAsErroredMutableliveData.postValue(Resource.success(response)) }
                result.onError {th,_->
                    setInternalErrorOccured()
                    markTransactionAsErroredMutableliveData.postValue(Resource.error(th.message?:Global.API_FAILURE)) }
            }
        }
    }

    fun updateBrokerInDb(broker:String)
    {
        val sanitizedBroker =if (gateWayRepo.isLeprechaunConnected() && !broker.contains("-leprechaun"))
            broker.plus("-leprechaun") else broker
        uiScope.launch {
            gateWayRepo.updateBrokerInDb(UpdateBrokerInDbBody(transactionId,Update(sanitizedBroker)))
        }
    }

    fun updateDeviceType()
    {
        uiScope.launch {
            gateWayRepo.updateDeviceTypeInDb(UpdateDeviceTypeBody(transactionId, UpdateDeviceType("android")))
        }
    }

    fun updateConsent()
    {
        uiScope.launch {
            gateWayRepo.updateConsentInDb(UpdateConsent(transactionId,UpdateConsentInDb(true)))
        }
    }
}