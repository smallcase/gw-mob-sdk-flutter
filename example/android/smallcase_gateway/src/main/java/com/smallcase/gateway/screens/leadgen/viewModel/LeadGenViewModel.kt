package com.smallcase.gateway.screens.leadgen.viewModel

import android.net.Uri
import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.screens.base.BaseViewModel
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import java.lang.StringBuilder
import javax.inject.Inject

class LeadGenViewModel @Inject constructor(
    private val configRepository: ConfigRepository,
    private val gateWayRepo: GateWayRepo
) : BaseViewModel(configRepository, gateWayRepo) {

    private val env = gateWayRepo.getBuildType()

    fun getWebViewUrl(params:HashMap<String,String>?):String{
        val uri = Uri.parse(when(env){
            SessionManager.DEVELOPMENT->"https://dev.smallcase.com/gateway-signup"
            SessionManager.STAGING->"https://stag.smallcase.com/gateway-signup"
            else->"https://www.smallcase.com/gateway-signup"
        }).buildUpon()
        uri.appendQueryParameter("deviceType","android")
        uri.appendQueryParameter("showCloseBtn","true")
        uri.appendQueryParameter("gateway",gateWayRepo.getTargetDistributor())

        params?.let {map->
            map.keys.forEach {
                uri.appendQueryParameter(it,map[it])
            }
        }

        return uri.build().toString()
    }
}
