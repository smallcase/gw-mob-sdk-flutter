package com.smallcase.gateway.screens.connect.activity

import android.app.Activity
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import com.smallcase.gateway.R
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.screens.transaction.activity.TransactionProcessActivity
import com.smallcase.gateway.utils.makeSpannable
import kotlinx.android.synthetic.main.activity_connected_consent.*
import coil.api.load
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.extensions.setOrientation
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.connect.viewModel.ConnectActivityViewModel
import javax.inject.Inject


class ConnectedConsentActivity : AppCompatActivity() {

    @Inject
    lateinit var viewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(
            this,
            viewModelFactory
        )[ConnectActivityViewModel::class.java]
    }

    companion object {
        const val INTENT_TYPE = "intentType"
        const val URL = "url"
        const val BROKER_CONFIG= "brokerConfig"
        fun launch(activity: Activity, url: String, intentType: String,brokerConfig:BrokerConfig) {
            val intent = Intent(activity, ConnectedConsentActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.putExtra(URL, url)
            intent.putExtra(INTENT_TYPE, intentType)
            intent.putExtra(BROKER_CONFIG,brokerConfig)
            activity.startActivity(intent)
        }
    }

    private var intentType = ""
    private var webUrlToLaunch = ""
    private var brokerConfig:BrokerConfig? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        LibraryCore.getInstance().dispatchingAndroidInjector.inject(this)
        this.setOrientation()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_connected_consent)
        processIntent()
    }

    private fun processIntent(){
        if (intent != null && intent.extras != null) {
            if (intent.hasExtra(INTENT_TYPE)) {
                intentType = intent?.extras?.getString(TransactionProcessActivity.INTENT_TYPE) ?: ""
            }
            if (intent.hasExtra(URL)) {
                webUrlToLaunch = intent?.extras?.getString(TransactionProcessActivity.URL) ?: ""

            }

            if (intent.hasExtra(BROKER_CONFIG)) {
                brokerConfig = intent?.extras?.getParcelable(BROKER_CONFIG)

            }

            initLayout()

        }
    }

    private fun initLayout(){
        tv_connected_consent_subTitle.text = getString(R.string.connected_consent_subTitle,brokerConfig?.brokerShortName)
        tv_connected_consent_text.text = makeSpannable(viewModel.processConfigBasedUiStringLocally(brokerConfig?.gatewayLoginConsent!!),"\\${BrokerChooserActivity.styleTagOpening}.*?\\${BrokerChooserActivity.styleTagClosing}",
            BrokerChooserActivity.styleTagOpening,
            BrokerChooserActivity.styleTagClosing
        )
        iv_select_broker_image.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${brokerConfig?.broker}.png") {
            crossfade(true)
        }

        tv_broker_name.text = getString(R.string.continue_with_broker,brokerConfig?.brokerShortName)

        ll_connected_consent_broker.setOnClickListener{_->
            viewModel.updateConsent()
            TransactionProcessActivity.launch(
                this,
                webUrlToLaunch,
                intentType
            )
            this.finish()
        }

        iv_connected_consent_closebt.setOnClickListener{_->
            markUserDeniedConsent()
        }

    }

    override fun onBackPressed() {
       markUserDeniedConsent()
    }

    private fun markUserDeniedConsent(){
        viewModel.markTransactionAsErrored(
            SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.error,
            SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.code)
        viewModel.setGatewayTransactionStatus(
            false,
            SmallcaseGatewaySdk.Result.ERROR,
            null,
            SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.code,
            SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.error
        )
        finish()
    }


}