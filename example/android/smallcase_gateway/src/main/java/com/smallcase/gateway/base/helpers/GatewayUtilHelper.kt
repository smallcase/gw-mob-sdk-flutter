package com.smallcase.gateway.base.helpers

import com.airbnb.lottie.LottieAnimationView
import com.smallcase.gateway.R
import com.smallcase.gateway.data.ApiFactory
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import java.lang.Exception

object GatewayUtilHelper {

    /*
    * Take the string from copy config and replaces broker, distributor and smallcase name is present in repo and the input string*/
    fun processConfigBasedUiString(input: String, brokerName: String?, distributerName: String?, smallcaseName: String?): String {
        var output = input

        if (brokerName != null && brokerName.isNotEmpty()) {
            output = output.replace("<BROKER>", brokerName)
        }
        if (distributerName != null && distributerName.isNotEmpty()) {
            output = output.replace("<DISTRIBUTOR>", distributerName)
        }
        if (smallcaseName != null && smallcaseName.isNotEmpty()) {
            output = output.replace("<SMALLCASE>", smallcaseName)
        }
        return output
    }

    /*
    * Take the string from copy config and replaces broker, distributor and smallcase name is present in repo and the input string*/
    fun processConfigBasedUiStringLocally(input: String,gateWayRepo: GateWayRepo): String {
        var output = input
        if (gateWayRepo.getTargetBrokerDisplayName() != null && gateWayRepo.getTargetBrokerDisplayName()!!.isNotEmpty()) {
            output = output.replace("<BROKER>", gateWayRepo.getTargetBrokerDisplayName()!!)
        }
        if (gateWayRepo.getTargetDistributor().isNotEmpty()) {
            output = output.replace("<DISTRIBUTOR>", gateWayRepo.getTargetDistributor())
        }
        if (gateWayRepo.getSmallcaseName().isNotEmpty()) {
            output = output.replace("<SMALLCASE>", gateWayRepo.getSmallcaseName())
        }
        return output
    }

    /*
        Switches loader animation based on gateway
        Currently only tickertape is given special loader, in rest all cases smallcase loader will be shown
        if loader is required to be shown

     */
    fun setLoaderLottie(view: LottieAnimationView,gateWayRepo: GateWayRepo) {
        try {
            if (gateWayRepo.getCurrentGateway().contains("tickertape")) {
                view.setAnimation(R.raw.tickertape_loader)
            } else {
                view.setAnimation(R.raw.smallcase_loader)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun processTwitterHandleText(text:String,twitterHandle:String):String{
        return text.replace("<BROKER_TWEET_HANDLE>",twitterHandle)
    }
}
