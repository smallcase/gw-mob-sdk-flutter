package com.smallcase.gateway.data.models

import com.google.gson.annotations.SerializedName

data class UiConfigItem(

    @SerializedName("connect")
    val connect: Connect? = null,

    @SerializedName("pre-broker-chooser")
    val preBrokerChooser: PreBrokerChooser? = null,

    @SerializedName("pre-connect")
    val preConnect: PreConnect? = null,

    @SerializedName("post-connect")
    val postConnect: PostConnect? = null,

    @SerializedName("verifying-login")
    val verifyingLogin: VerifyingLogin? = null,

    @SerializedName("order-cancelled")
    val orderCancelled: OrderCancelled? = null,

    @SerializedName("login-failed")
    val loginFailed: LoginFailed? = null,

    @SerializedName("click-to-continue")
    val clickToContinue: ClickToContinue? = null,

    @SerializedName("orderflow-waiting")
    val orderflowWaiting: OrderflowWaiting? = null,

    @SerializedName("order-in-queue")
    val orderInQueue: OrderInQueue? = null,

    @SerializedName("post-holdings-import")
    val postImportHoldings: PostImportHoldings? = null


)

data class PreBrokerChooser(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false

)

data class VerifyingLogin(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false

)

data class PreConnect(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class PostConnect(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class OrderInQueue(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class OrderflowWaiting(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class OrderCancelled(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("withError")
    val withError: String? = null,

    @SerializedName("withoutError")
    val withoutError: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class LoginFailed(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("wrongUser")
    val wrongUser: String? = null,

    @SerializedName("defaultError")
    val defaultError: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class Connect(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false,

    @SerializedName("showTweet")
    val showTweet:Boolean = false,

    @SerializedName("tweetMessage")
    val tweetMessage:String?
)

data class ClickToContinue(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false
)

data class PostImportHoldings(

    @SerializedName("title")
    val title: String? = null,

    @SerializedName("subTitle")
    val subTitle: String? = null,

    @SerializedName("show")
    val show: Boolean = false

)
