package com.smallcase.gateway.screens.transaction.viewModel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.models.BaseReponseDataModel
import com.smallcase.gateway.data.models.TransactionPollStatusResponse
import com.smallcase.gateway.enums.PollTransactionStatus
import com.smallcase.gateway.network.Resource
import com.smallcase.gateway.network.onError
import com.smallcase.gateway.network.onSuccess
import com.smallcase.gateway.screens.base.BaseViewModel
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import kotlinx.coroutines.launch
import javax.inject.Inject

class TransactionActivityViewModel @Inject constructor(
    private val configRepository: ConfigRepository,
    private val gateWayRepo: GateWayRepo
) :BaseViewModel(configRepository, gateWayRepo)
{
    var intentType = ""//SdkConstants.TransactionIntent.CONNECT
    var WEB_URL_TO_LAUNCH = ""
    val preConnectConfigs
        get() = uiConfigs.preConnect

    val postConnectConfigs
    get() = uiConfigs.postConnect

    val loginFailedConfigs
    get() = uiConfigs.loginFailed

    val orderFlowWaitingConfigs
    get() = uiConfigs.orderflowWaiting

    val orderInQueueConfigs
    get() = uiConfigs.orderInQueue

    val postImportHoldingsConfigs
    get() = uiConfigs.postImportHoldings




    fun getTransactionPollingStatus(type: PollTransactionStatus)
    {

            uiScope.launch {
                gateWayRepo.getTransactionPoolingStatus(transactionId).also {result ->
                    result.onSuccess {
                        when (type) {
                            PollTransactionStatus.PollForTransactionStatus -> pollForTransactionStatusMutableLiveData.postValue(
                                Resource.success(it)
                            )
                            PollTransactionStatus.TransactionStatus -> getTransactionStatusMutableLiveData.postValue(
                                Resource.success(it)
                            )
                            PollTransactionStatus.ForcedTransactionStatus -> getForcedTransactionStatusMutableLiveData.postValue(
                                Resource.success(it)
                            )
                            PollTransactionStatus.CancelTransactionStatus -> getCancelTransactionStatusMutableLiveData.postValue(
                                Resource.success(it)
                            )
                        }
                    }
                    result.onError {th,_-> setInternalErrorOccured()
                        when (type) {
                            PollTransactionStatus.PollForTransactionStatus -> pollForTransactionStatusMutableLiveData.postValue(
                                Resource.error(th.message?:Global.API_FAILURE)
                            )
                            PollTransactionStatus.TransactionStatus -> getTransactionStatusMutableLiveData.postValue(
                                Resource.error(th.message?:Global.API_FAILURE)
                            )
                            PollTransactionStatus.ForcedTransactionStatus -> getForcedTransactionStatusMutableLiveData.postValue(
                                Resource.error(th.message?:Global.API_FAILURE)
                            )
                            PollTransactionStatus.CancelTransactionStatus -> getCancelTransactionStatusMutableLiveData.postValue(
                                Resource.error(th.message?:Global.API_FAILURE)
                            )
                        }
                    }

                }
            }

    }

    /**
     * Different transaction polling status Livedata
     */
    val pollForTransactionStatusLiveData:LiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> by lazy { pollForTransactionStatusMutableLiveData }

    private val pollForTransactionStatusMutableLiveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> ()
    }

    val getTransactionStatusLiveData:LiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> by lazy { getTransactionStatusMutableLiveData }

    private val getTransactionStatusMutableLiveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> ()
    }

    val getForcedTransactionStatusLiveData:LiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> by lazy { getForcedTransactionStatusMutableLiveData }


    private val getForcedTransactionStatusMutableLiveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> ()
    }

    val getCancelTransactionStatusLiveData:LiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> by lazy { getCancelTransactionStatusMutableLiveData }


    private val getCancelTransactionStatusMutableLiveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> ()
    }



    val markTransactionAsCancelledLiveData:LiveData<Resource<BaseReponseDataModel<Boolean>>> by lazy { markTransactionAsCancelledMutableLiveData }

    private val markTransactionAsCancelledMutableLiveData by lazy {
        MutableLiveData<Resource<BaseReponseDataModel<Boolean>>>()
    }




    fun setSmallcaseAuthToken(smallcaseAuthToken:String)
    {
        gateWayRepo.setSmallcaseAuthToken(smallcaseAuthToken)
    }





    fun markTransacTionAsCancelled(){
        uiScope.launch {
            gateWayRepo.markTransactionAsCancelled(transactionId).also {result ->
                result.onSuccess { markTransactionAsCancelledMutableLiveData.postValue(Resource.success(it)) }
                result.onError {th,_->
                    setInternalErrorOccured()
                    markTransactionAsCancelledMutableLiveData.postValue(Resource.error(th.message?:Global.API_FAILURE)) }

            }
        }
    }




}

