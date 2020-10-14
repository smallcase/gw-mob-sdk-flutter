package com.smallcase.gateway.data.adapters

import com.google.gson.Gson
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.smallcase.gateway.data.models.ClickToContinue
import com.smallcase.gateway.data.models.Connect
import com.smallcase.gateway.data.models.LoginFailed
import com.smallcase.gateway.data.models.OrderCancelled
import com.smallcase.gateway.data.models.OrderInQueue
import com.smallcase.gateway.data.models.OrderflowWaiting
import com.smallcase.gateway.data.models.PostConnect
import com.smallcase.gateway.data.models.PreBrokerChooser
import com.smallcase.gateway.data.models.PreConnect
import com.smallcase.gateway.data.models.UiConfigItem
import com.smallcase.gateway.data.models.VerifyingLogin
import java.lang.reflect.Type

/**
 *Parser for the parsing the copy config data in to required map
 **/
class UiConfigParserAdapter(val gson: Gson) : JsonDeserializer<UiConfigItem> {

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): UiConfigItem {
        if (json !== null) {

            if (json is JsonObject) {
                var connect: Connect? = null
                var preBrokerChooser: PreBrokerChooser? = null
                var preConnect: PreConnect? = null
                var postConnect: PostConnect? = null
                var verifyingLogin: VerifyingLogin? = null
                var orderCancelled: OrderCancelled? = null
                var loginFailed: LoginFailed? = null
                var clickToContinue: ClickToContinue? = null
                var orderflowWaiting: OrderflowWaiting? = null
                var orderInQueue: OrderInQueue? = null

                if (json.get("pre-broker-chooser") != null) {
                    preBrokerChooser = gson.fromJson(
                        json.getAsJsonObject("pre-broker-chooser"),
                        PreBrokerChooser::class.java
                    )
                }
                if (json.get("connect") != null) {
                    connect = gson.fromJson(json.getAsJsonObject("connect"), Connect::class.java)
                }
                if (json.get("pre-connect") != null) {
                    preConnect =
                        gson.fromJson(json.getAsJsonObject("pre-connect"), PreConnect::class.java)
                }
                if (json.get("verifying-login") != null) {
                    verifyingLogin =
                        gson.fromJson(
                            json.getAsJsonObject("verifying-login"),
                            VerifyingLogin::class.java
                        )
                }
                if (json.get("post-connect") != null) {
                    postConnect =
                        gson.fromJson(json.getAsJsonObject("post-connect"), PostConnect::class.java)
                }
                if (json.get("order-cancelled") != null) {
                    orderCancelled = gson.fromJson(
                        json.getAsJsonObject("order-cancelled"),
                        OrderCancelled::class.java
                    )
                }
                if (json.get("login-failed") != null) {
                    loginFailed =
                        gson.fromJson(json.getAsJsonObject("login-failed"), LoginFailed::class.java)
                }
                if (json.get("click-to-continue") != null) {
                    clickToContinue = gson.fromJson(
                        json.getAsJsonObject("click-to-continue"),
                        ClickToContinue::class.java
                    )
                }
                if (json.get("orderflow-waiting") != null) {
                    orderflowWaiting = gson.fromJson(
                        json.getAsJsonObject("orderflow-waiting"),
                        OrderflowWaiting::class.java
                    )
                }
                if (json.get("order-in-queue") != null) {
                    orderInQueue = gson.fromJson(
                        json.getAsJsonObject("order-in-queue"),
                        OrderInQueue::class.java
                    )
                }

                var uiConfigItem = UiConfigItem(
                    connect,
                    preBrokerChooser,
                    preConnect,
                    postConnect,
                    verifyingLogin,
                    orderCancelled,
                    loginFailed,
                    clickToContinue,
                    orderflowWaiting,
                    orderInQueue
                )

                return uiConfigItem
            } else {
                throw Exception("copy config can not be null")
            }
        } else {
            return UiConfigItem()
        }
        // throw Exception("copy config can not be null")
    }
}

// class UiConfigParserAdapter {
//
//    @ToJson
//    fun toJson(uiConfigMap: HashMap<String, UiConfigItem>): String {
//        return ""
//    }
//
//    @FromJson
//    fun fromJson(reader: JsonReader): HashMap<String, UiConfigItem> {
//        val uiConfigMap = HashMap<String, UiConfigItem>()
//        reader.beginObject()
//        while (reader.hasNext()) {
//            var gateway: String = reader.nextName()
//
//            var connect: Connect? = null
//            var preBrokerChooser: PreBrokerChooser? = null
//            var preConnect: PreConnect? = null
//            var postConnect: PostConnect? = null
//            var verifyingLogin: VerifyingLogin? = null
//            var orderCancelled: OrderCancelled? = null
//            var loginFailed: LoginFailed? = null
//            var clickToContinue: ClickToContinue? = null
//            var orderflowWaiting: OrderflowWaiting? = null
//            var orderInQueue: OrderInQueue? = null
//
//            reader.beginObject()
//
//            while (reader.hasNext()) {
//                val fieldName = reader.nextName().toLowerCase()
//
//                // temp patch
//                // val showValue = true
//
//                reader.beginObject()
//                when (fieldName) {
//                    "connect" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        connect = Connect(titleValue, subTitleValue, showValue)
//                    }
//                    "pre-broker-chooser" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        preBrokerChooser = PreBrokerChooser(titleValue, subTitleValue, showValue)
//                    }
//                    "pre-connect" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        preConnect = PreConnect(titleValue, subTitleValue, showValue)
//                    }
//                    "post-connect" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        postConnect = PostConnect(titleValue, subTitleValue, showValue)
//                    }
//                    "verifying-login" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//                        verifyingLogin = VerifyingLogin(titleValue, subTitleValue, showValue)
//                    }
//                    "order-cancelled" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val withErrorKey = reader.nextName()
//                        val withErrorValue = reader.nextString()
//
//                        val withoutErrorKey = reader.nextName()
//                        val withoutErrorValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        orderCancelled =
//                            OrderCancelled(titleValue, withErrorValue, withoutErrorValue, showValue)
//                    }
//                    "login-failed" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val wrongUserKey = reader.nextName()
//                        val wrongUserValue = reader.nextString()
//
//                        val defaultErrorKey = reader.nextName()
//                        val defaultErrorValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//                        loginFailed = LoginFailed(titleValue, wrongUserValue, defaultErrorValue, showValue)
//                    }
//
//                    "click-to-continue" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        clickToContinue =
//                            ClickToContinue(titleValue, subTitleValue, showValue)
//                    }
//                    "orderflow-waiting" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        orderflowWaiting =
//                            OrderflowWaiting(titleValue, subTitleValue, showValue)
//                    }
//                    "order-in-queue" -> {
//                        val titleKey = reader.nextName()
//                        val titleValue = reader.nextString()
//
//                        val subTitleKey = reader.nextName()
//                        val subTitleValue = reader.nextString()
//
//                        val showKey = reader.nextName()
//                        val showValue = reader.nextBoolean()
//
//                        orderInQueue =
//                            OrderInQueue(titleValue, subTitleValue, showValue)
//                    }
//                }
//                reader.endObject()
//            }
//            reader.endObject()
//
//            var uiConfigItem = UiConfigItem(
//                connect,
//                preBrokerChooser,
//                preConnect,
//                postConnect,
//                verifyingLogin,
//                orderCancelled,
//                loginFailed,
//                clickToContinue,
//                orderflowWaiting,
//                orderInQueue
//            )
//
//            uiConfigMap[gateway] = uiConfigItem
//        }
//        reader.endObject()
//
//        return uiConfigMap
//    }
// }
