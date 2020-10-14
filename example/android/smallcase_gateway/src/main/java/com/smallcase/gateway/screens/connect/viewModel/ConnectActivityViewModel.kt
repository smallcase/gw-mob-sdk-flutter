package com.smallcase.gateway.screens.connect.viewModel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.models.BaseReponseDataModel
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.BrokerRedirectParams
import com.smallcase.gateway.network.Resource
import com.smallcase.gateway.network.onError
import com.smallcase.gateway.network.onSuccess
import com.smallcase.gateway.screens.base.BaseViewModel
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import kotlinx.coroutines.launch
import javax.inject.Inject

class ConnectActivityViewModel @Inject constructor(
    private val configRepository: ConfigRepository,
    private val gateWayRepo: GateWayRepo
) : BaseViewModel(configRepository, gateWayRepo) {

    val preBrokerChooserConfigs
        get() = uiConfigs.preBrokerChooser

    val connectConfigs
        get() = uiConfigs.connect

    val connectedUserDataModel
        get() = gateWayRepo.getConnectedUserData()

    val isConnectedUser
        get() = gateWayRepo.isUserConnected()

    val getBrokerParamsUrl by lazy {
        getBrokerParamsUrl(urlParam)
    }


    private var mModeSwitchCount = 0

    val toBeShownBrokersList by lazy {
        generateBrookerChooser()
    }

    val brokersShownInOptions by lazy {
        ArrayList<BrokerConfig>()
    }
    var currentlySelectBroker: BrokerConfig? = null

    val isLeprechaunConnected
    get() = gateWayRepo.isLeprechaunConnected()

    var WEB_URL_TO_LAUNCH =
        "https://zerodha-dev.smallcase.com/transaction/123456789?action=gatewaynativetransaction&gateway=gatewaydemo"

    var urlParam:String=""
    var intent:String =""









    /**
     * Triggers refresh of brokers list in repo if not already available
     * */
    fun getBrokerConfigs() {
        configRepository.getBrokerConfig()
    }





    private fun getBrokerParamsUrl(urlParam:String):LiveData<Resource<BaseReponseDataModel<BrokerRedirectParams>>>
    {
        return MutableLiveData<Resource<BaseReponseDataModel<BrokerRedirectParams>>>().also {mutableLiveData->
            uiScope.launch {
                currentlySelectBroker?.broker?.let {currentBroker->
                    gateWayRepo.getBrokerRedirectParams(urlParam,currentBroker).also {result ->
                        result.onSuccess {
                            WEB_URL_TO_LAUNCH= currentlySelectBroker?.baseLoginURL + "?" + it.data?.redirectParams +
                                    "&gateway=${currentGateway}"
                            mutableLiveData.postValue(Resource.success(it)) }
                        result.onError {th,_->
                            gateWayRepo.setInternalErrorOccured()
                            mutableLiveData.postValue(Resource.error(th.message?:Global.API_FAILURE)) }

                    }

                }

            }
        }

    }






    fun setIsLeprechaunConnected(isConnected: Boolean) {
        gateWayRepo.setIsLeprechaunConnected(isConnected)
    }

    fun handleLeprechaunMode(showToast: () -> Unit) {
        if (mModeSwitchCount == 10) {
            setIsLeprechaunConnected(true)
            showToast()
        } else mModeSwitchCount++

    }



    private fun generateBrookerChooser(): List<BrokerConfig> {

        val allowedBroker:List<String> = when(gateWayRepo.getCurrentIntent()){
            SdkConstants.TransactionIntent.CONNECT->{gateWayRepo.getAllowedBroker().get(SdkConstants.AllowedBrokers.CONNECT) ?: ArrayList()}
            SdkConstants.TransactionIntent.TRANSACTION->{gateWayRepo.getAllowedBroker().get(SdkConstants.AllowedBrokers.SST) ?: ArrayList()}
            else->{gateWayRepo.getAllowedBroker().get(SdkConstants.AllowedBrokers.HOLDINGS_IMPORT) ?: ArrayList()}
        }
        Log.e("mytag",allowedBroker.toString())
        val filteredBrokersList: ArrayList<BrokerConfig> = ArrayList()
        /**
         * First priority is of the connected broker of the user, and if this broker is LEPRECHAUN then turn on the
         * leprechaun mode ON in the SDK
         * */

        if (isConnectedUser && connectedUserDataModel != null) {
            // user is already connected, login for only connected broker

            val connectedBroker = connectedUserDataModel?.broker?.name
            if (connectedBroker?.contains("-${Global.LEPRECHAUN}") == true) {
                setIsLeprechaunConnected(true)
            }
            filteredBrokersList.addAll(configRepository.getBrokerConfig().filter {
                if (it.broker!=null)
                    connectedBroker?.contains(it.broker!!) == true
                else false
            })

        }
        /**
         * Second priority is given to the preSelectedBrokers list (if set) from the SetUp method
         * This allows to narrow the list of brokers dependency on support of the gateway owners
         * */
        else if (gateWayRepo.getPreRequestedBrokers() != null && gateWayRepo.getPreRequestedBrokers()?.isNotEmpty() == true) {
            val intersectedList=gateWayRepo.getPreRequestedBrokers()?.intersect(allowedBroker)


            // if init includes preRequested brokers then show only those brokers
            for (brokerItem in configRepository.getBrokerConfig()) {
                if (intersectedList?.contains(brokerItem.broker) == true) {
                    filteredBrokersList.add(brokerItem)
                }
            }
        }

        // If there is only one broker in the list, launch that broker directly else show all the brokers selection
        if (filteredBrokersList.isEmpty() && gateWayRepo.getPreRequestedBrokers().isNullOrEmpty()) {
            configRepository.getBrokerConfig().forEach {
                if (allowedBroker.contains(it.broker))
                {
                    filteredBrokersList.add(it)
                }
            }

        }

        // filter item that are gateway visible, in case of only one broker in the filtered list, launch for that broker without the filter
        val sortedList=
            if (filteredBrokersList.size<=9)
            {
                filteredBrokersList.toMutableList()
            }else
            {
                filteredBrokersList.filter { it.topBroker == true }.toMutableList().also {
                    it.addAll(filteredBrokersList.filter { it.topBroker == false }.sortedBy { it.brokerShortName })
                }
            }

        if (sortedList.size>9)
        {
            brokersShownInOptions.clear()
            brokersShownInOptions.addAll(sortedList.subList(9,sortedList.size))
        }
        Log.e("mytag",brokersShownInOptions.toString())
        return (if(sortedList.size>9)sortedList.subList(0,9) else sortedList).sortedBy { it.brokerShortName }
    }




    /**
     * Launch the flow for the requested broker
     * also set the request broker currently as primary into the repo by calling setTargetBroker()
     * */
    fun launchBrokerPageFor(brokerConfig:BrokerConfig,version:String):String
    {
        currentlySelectBroker=brokerConfig
        gateWayRepo.setTargetBroker(brokerConfig)

        return when{
            (brokerConfig.isIframePlatform && !isLeprechaunConnected)->{
                /**
                 * If the broker is of Iframe category and the leprechaun mode is OFF
                 * */
                ("/gatewaytransaction/${gateWayRepo.getTransactionId()}" +
                        "?action=gatewaynativetransaction" +
                        "&broker=${brokerConfig.broker}" +
                        "&gateway=${currentGateway}" +
                        "&trxid=${transactionId}" +
                        "&deviceType=${Global.DEVICE_TYPE}" +
                        if (gateWayRepo.getBuildType().contains("staging")) {
                            "&staging=true"
                        } else {
                            ""
                        } +
                        "&v=$version").also {
                    urlParam=it }
            }
            gateWayRepo.isLeprechaunConnected()->{
                /**
                 * If leprechaun mode is ON
                 * */
                (brokerConfig.leprechaunURL +
                    "/gatewaytransaction/${gateWayRepo.getTransactionId()}" +
                    "?action=gatewaynativetransaction" +
                    "&broker=${brokerConfig.broker}-${Global.LEPRECHAUN}" +
                    "&gateway=${currentGateway}" +
                    "&trxid=${transactionId}" +
                    "&deviceType=${Global.DEVICE_TYPE}" +
                    if (gateWayRepo.getBuildType().contains("staging")) {
                        "&staging=true"
                    } else {
                        ""
                    }+
                    "&v=$version"    ).also {
                    WEB_URL_TO_LAUNCH=it
                }
            }

            else->{
                /**
                 * All other cases
                 * */
                (brokerConfig.platformURL +
                        "/gatewaytransaction/${gateWayRepo.getTransactionId()}" +
                        "?action=gatewaynativetransaction" +
                        "&broker=${brokerConfig.broker}" +
                        "&gateway=${currentGateway}" +
                        "&trxid=${transactionId}" +
                        "&deviceType=${Global.DEVICE_TYPE}" +
                        if (gateWayRepo.getBuildType().contains("staging")) {
                            "&staging=true"
                        } else {
                            ""
                        } +
                        "&v=$version").also {
                    WEB_URL_TO_LAUNCH=it
                }
            }
        }

    }


    fun setCurrentIntent(intent:String)
    { gateWayRepo.setCurrentIntent(intent) }



}