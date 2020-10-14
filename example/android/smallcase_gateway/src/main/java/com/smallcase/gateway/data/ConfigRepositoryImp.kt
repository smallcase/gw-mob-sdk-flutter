package com.smallcase.gateway.data

import android.util.Log
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.UiConfigItem
import com.smallcase.gateway.data.models.tweetConfig.TweetConfigDTO
import com.smallcase.gateway.data.models.tweetConfig.UpcomingBroker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import com.smallcase.gateway.network.Result
import com.smallcase.gateway.network.apiInterface.ConfigService
import com.smallcase.gateway.network.apiInterface.FakeApiService
import com.smallcase.gateway.network.apiInterface.GatewayApiService
import com.smallcase.gateway.network.onError
import com.smallcase.gateway.network.onSuccess
import com.smallcase.gateway.screens.base.BaseRepo
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Remote dependent resources are stored and are served through config service
 * As soon as possible, store the config for brokers and config for all environments
 * currently done for prod, dev and staging
 * **/
@Singleton
class ConfigRepositoryImp @Inject constructor(private val configApiService: ConfigService, private val gatewayApiService:GatewayApiService, private val sessionManager: SessionManager,private val fakeApiService: FakeApiService) : ConfigRepository,BaseRepo() {



    private suspend fun getBrokerConfigs(buildType:String): Result<List<BrokerConfig>> = configApiService.getBrokerConfigs(buildType).getResult()

    private suspend fun getUiConfigs(buildType: String):Result<HashMap<String, UiConfigItem>> = configApiService.getUiConfig(buildType).getResult()

    private suspend fun getTweetConfigs(buildType: String):Result<TweetConfigDTO> = configApiService.getTweetConfig(buildType).getResult()

    private suspend fun getPartnerConfig(gateway:String):Result<HashMap<String, UiConfigItem>> = gatewayApiService.getPartnerConfig(gateway).getResult()

    //private suspend fun getPartnerConfigFake(gateway: String):Result<HashMap<String, UiConfigItem>> = fakeApiService.getPartnerConfig(gateway).getResult()

    //private suspend fun getBrokerConfigsFake(buildType:String): Result<List<BrokerConfig>> = fakeApiService.getBrokerConfigs(buildType).getResult()

    override fun loadTweetConfig() {
        CoroutineScope(Dispatchers.IO).launch {
            getTweetConfigs(sessionManager.BUILD_VARIANT).also {
                it.onSuccess {
                    sessionManager.tweetConfig[sessionManager.BUILD_VARIANT]=it
                }
            }
        }
    }

    override fun loadBrokerConfig() {
        CoroutineScope(Dispatchers.IO).launch {
            getBrokerConfigs(sessionManager.BUILD_VARIANT).also {
                it.onSuccess {
                    sessionManager.brokerConfig[sessionManager.BUILD_VARIANT]=it
                }
            }
        }
    }

    override fun loadUiConfig() {
        CoroutineScope(Dispatchers.IO).launch {
            getUiConfigs(sessionManager.BUILD_VARIANT).also {
                it.onSuccess {
                    sessionManager.copyConfig[sessionManager.BUILD_VARIANT]=it
                }
            }
        }
    }

    override fun loadConfigData(variant: String, setupListener: SmallcaseGatewayListeners?) {
        // load ui config
        CoroutineScope(Dispatchers.IO).launch {

                    getBrokerConfigs(variant).also {
                        it.onSuccess {
                            sessionManager.brokerConfig[variant] = it
                            getTweetConfigs(variant).also {
                                it.onSuccess {
                                    sessionManager.tweetConfig[variant] = it
                                    getPartnerConfig(sessionManager.CURRENT_GATEWAY).also {
                                        it.onSuccess {
                                            it[Global.COPY_CONFIG]?.let {
                                                sessionManager.copyConfig[variant] = HashMap<String,UiConfigItem>().also {map->
                                                    map.put(sessionManager.CURRENT_GATEWAY,it)
                                                }
                                                withContext(Dispatchers.Main){
                                                    setupListener?.onGatewaySetupSuccessfull()
                                                }
                                            } ?: withContext(Dispatchers.Main){
                                                setupListener?.onGatewaySetupFailed("Something went wrong, please check your internet connection and try again")
                                            }


                                        }
                                        it.onError { throwable, i ->
                                            Log.e("mytag",i.toString())
                                            getUiConfigs(variant).also {
                                                it.onSuccess {
                                                    sessionManager.copyConfig[variant] = it
                                                    withContext(Dispatchers.Main){
                                                        setupListener?.onGatewaySetupSuccessfull()
                                                    }
                                                }
                                                it.onError {th,_->
                                                    th.printStackTrace()
                                                    withContext(Dispatchers.Main){
                                                        setupListener?.onGatewaySetupFailed("Something went wrong, please check your internet connection and try again")
                                                    }

                                                }
                                            }
                                        }
                                    }


                                }
                                it.onError {th,_->
                                    th.printStackTrace()
                                    withContext(Dispatchers.Main){
                                        setupListener?.onGatewaySetupFailed("Something went wrong, please check your internet connection and try again")
                                    }
                                }
                            }
                        }
                        it.onError {th,_->
                            th.printStackTrace()
                            withContext(Dispatchers.Main){
                                setupListener?.onGatewaySetupFailed("Something went wrong, please check your internet connection and try again")
                            }
                        }
                    }

        }
    }

    override fun getBrokerConfig(): List<BrokerConfig> {
        return if (sessionManager.brokerConfig[sessionManager.BUILD_VARIANT] == null) {
            //loadBrokerConfig()
            ArrayList()
        } else {
            return sessionManager.brokerConfig[sessionManager.BUILD_VARIANT]!!
        }
    }

    override fun getTweetConfig(): List<UpcomingBroker> {
        return if (sessionManager.tweetConfig[sessionManager.BUILD_VARIANT] == null) {
            //loadTweetConfig()
            ArrayList()
        } else {
            return sessionManager.tweetConfig[sessionManager.BUILD_VARIANT]!!.upcomingBrokers
        }
    }


    // remove leprachaun tag for broker, required for config settings
    override fun getUiConfig(): UiConfigItem {
        val buildVariant = sessionManager.BUILD_VARIANT
        val gateway = sessionManager.CURRENT_GATEWAY
        gateway.replace("-${Global.LEPRECHAUN}", "")
        if (sessionManager.copyConfig.isEmpty() || sessionManager.copyConfig[buildVariant] == null ||
            sessionManager.copyConfig[buildVariant]!!.isEmpty()
        ) {
           // loadUiConfig()
        }

        return when {
            sessionManager.copyConfig[buildVariant] == null -> UiConfigItem()
            sessionManager.copyConfig[buildVariant]!![gateway] == null -> if (sessionManager.copyConfig[buildVariant]!!["default"] != null) {
                sessionManager.copyConfig[buildVariant]!!["default"]!!
            } else {
                UiConfigItem()
            }
            else -> sessionManager.copyConfig[buildVariant]!![gateway]!!
        }
    }
}
