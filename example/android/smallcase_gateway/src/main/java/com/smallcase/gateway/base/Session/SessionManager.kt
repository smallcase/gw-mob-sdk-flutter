package com.smallcase.gateway.base.Session

import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.UiConfigItem
import com.smallcase.gateway.data.models.tweetConfig.TweetConfigDTO
import javax.inject.Singleton

/**
 * Wrapper class for all User Session related data
 **/
@Singleton
class SessionManager {

    companion object{
        const val PRODUCTION = "production"
        const val DEVELOPMENT = "development"
        const val STAGING = "staging"
    }
    var isConnected:Boolean=false
    var csrf:String=""
    var gatewayToken:String=""
    @Volatile
    var BUILD_VARIANT= DEVELOPMENT
    // would be setup by setup method
    var CURRENT_GATEWAY: String = "default"
    // Smallcase Auth token stored in the repo
    var CURRENT_SMALLCASE_AUTH_TOKEN: String = ""

    val brokerConfig: HashMap<String, List<BrokerConfig>> by lazy { HashMap<String, List<BrokerConfig>>() }
    val copyConfig: HashMap<String, HashMap<String, UiConfigItem>> by lazy { HashMap<String, HashMap<String, UiConfigItem>>() }
    val tweetConfig: HashMap<String,TweetConfigDTO> by lazy { HashMap<String,TweetConfigDTO>() }
    val allowedBrokers:HashMap<String,List<String>> by lazy { HashMap<String,List<String>>() }
    var currentIntent:String = ""

}
