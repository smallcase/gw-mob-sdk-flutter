package com.smallcase.gateway.data.models

import android.os.Parcel
import android.os.Parcelable
import com.google.gson.annotations.SerializedName

data class BrokerConfig(

    @SerializedName("brokerDisplayName")
    val brokerDisplayName: String? = null,

    @SerializedName("trustedBroker")
    val trustedBroker: Boolean? = null,

    @SerializedName("brokerShortName")
    val brokerShortName: String? = null,

    @SerializedName("platformURL")
    val platformURL: String,

    @SerializedName("visible")
    val visible: Boolean? = null,

    @SerializedName("leprechaunURL")
    val leprechaunURL: String,

    @SerializedName("baseLoginURL")
    val baseLoginURL: String,

    @SerializedName("isIframePlatform")
    val isIframePlatform: Boolean,

    @SerializedName("topBroker")
    val topBroker: Boolean? = null,

    @SerializedName("accountOpeningURL")
    val accountOpeningURL: String,

    @SerializedName("gatewayVisible")
    val gatewayVisible: Boolean? = null,

    @SerializedName("broker")
    var broker: String? = null,

    @SerializedName("isRedirectURL")
    val isRedirectURL: Boolean? = null,

    @SerializedName("popularity")
    val popularity: Int,

    @SerializedName("gatewayLoginConsent")
    val gatewayLoginConsent:String?
) : Parcelable {
    constructor(parcel: Parcel) : this(
        parcel.readString(),
        parcel.readValue(Boolean::class.java.classLoader) as? Boolean,
        parcel.readString(),
        parcel.readString()!!,
        parcel.readValue(Boolean::class.java.classLoader) as? Boolean,
        parcel.readString()!!,
        parcel.readString()!!,
        (parcel.readValue(Boolean::class.java.classLoader) as? Boolean)!!,
        parcel.readValue(Boolean::class.java.classLoader) as? Boolean,
        parcel.readString()!!,
        parcel.readValue(Boolean::class.java.classLoader) as? Boolean,
        parcel.readString(),
        parcel.readValue(Boolean::class.java.classLoader) as? Boolean,
        parcel.readInt(),
        parcel.readString()
    ) {
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(brokerDisplayName)
        parcel.writeValue(trustedBroker)
        parcel.writeString(brokerShortName)
        parcel.writeString(platformURL)
        parcel.writeValue(visible)
        parcel.writeString(leprechaunURL)
        parcel.writeString(baseLoginURL)
        parcel.writeValue(isIframePlatform)
        parcel.writeValue(topBroker)
        parcel.writeString(accountOpeningURL)
        parcel.writeValue(gatewayVisible)
        parcel.writeString(broker)
        parcel.writeValue(isRedirectURL)
        parcel.writeInt(popularity)
        parcel.writeString(gatewayLoginConsent)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<BrokerConfig> {
        override fun createFromParcel(parcel: Parcel): BrokerConfig {
            return BrokerConfig(parcel)
        }

        override fun newArray(size: Int): Array<BrokerConfig?> {
            return arrayOfNulls(size)
        }
    }
}
