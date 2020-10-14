package com.smallcase.gateway.data

import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.UiConfigItem
import com.smallcase.gateway.data.models.tweetConfig.TweetConfigDTO
import com.smallcase.gateway.data.models.tweetConfig.UpcomingBroker

interface ConfigRepository {
    fun loadBrokerConfig()
    fun loadUiConfig()
    fun loadTweetConfig()
    fun loadConfigData(variant: String, setupListener: SmallcaseGatewayListeners?)
    fun getBrokerConfig(): List<BrokerConfig>
    fun getUiConfig(): UiConfigItem
    fun getTweetConfig():List<UpcomingBroker>
}
