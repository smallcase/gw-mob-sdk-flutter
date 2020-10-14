package com.smallcase.gateway.data.models.tweetConfig

data class UpcomingBroker(
    val broker: String,
    val brokerDisplayName: String,
    val twitterHandle: String,
    val upcoming: Boolean,
    val visible: Boolean
)