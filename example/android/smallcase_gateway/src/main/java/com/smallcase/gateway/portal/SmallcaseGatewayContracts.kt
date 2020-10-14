package com.smallcase.gateway.portal

import android.app.Activity
import com.smallcase.gateway.data.SmallcaseGatewayListeners
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.listeners.TransactionResponseListener
import com.smallcase.gateway.data.models.Environment
import com.smallcase.gateway.data.models.InitialisationResponse
import com.smallcase.gateway.data.models.SmallcaseGatewayDataResponse
import com.smallcase.gateway.data.requests.InitRequest

interface SmallcaseGatewayContracts {

    fun setConfigEnvironment(environment: Environment, smallcaseGatewayListeners: SmallcaseGatewayListeners)

    fun triggerTransaction(
        activity: Activity,
        transactionId: String,
        transactionResponseListener: TransactionResponseListener
    )

    fun triggerLeadGen(
        activity: Activity,
        params:HashMap<String,String>?
    )

    // Available for guest users

    fun init(authRequest: InitRequest, gatewayInitialisationListener: DataListener<InitialisationResponse>?)
    fun getSmallcases(sortBy: String?, sortOrder: Int?, smallcasesListener: DataListener<SmallcaseGatewayDataResponse>) {}

    fun getSmallcaseProfile(scid: String, smallcaseProfileListener: DataListener<SmallcaseGatewayDataResponse>) {}

    fun getSmallcaseNews(scid: String?, iScid: String?, count: Int?, offset: Int?, smallcaseNewsListener: DataListener<SmallcaseGatewayDataResponse>) {}

    // Requires a connected user

    fun getUserInvestments(iScids: List<String>?, smallcaseInvestmentsListener: DataListener<SmallcaseGatewayDataResponse>) {}
    fun getHistorical(scid: String, benchmarkId: String, benchmarkType: String, duration: String?, base: Int, smallcaseHistoricalListener: DataListener<SmallcaseGatewayDataResponse>) {}

    fun getExitedSmallcases(exitedSmallcasesListener: DataListener<SmallcaseGatewayDataResponse>) {}

    fun getUserInvestmentDetails(iScid: String, userInvestmentDetailsListener: DataListener<SmallcaseGatewayDataResponse>) {}
}
