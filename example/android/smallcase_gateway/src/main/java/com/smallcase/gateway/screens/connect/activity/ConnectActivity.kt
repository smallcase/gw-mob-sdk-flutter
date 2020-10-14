package com.smallcase.gateway.screens.connect.activity

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.smallcase.gateway.R
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.extensions.setOrientation
import com.smallcase.gateway.network.Status
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.connect.viewModel.ConnectActivityViewModel
import kotlinx.android.synthetic.main.activity_gateway_connect.*
import javax.inject.Inject

class ConnectActivity : AppCompatActivity() {

    @Inject
    lateinit var viewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(
            this,
            viewModelFactory
        )[ConnectActivityViewModel::class.java]
    }


    private val handler by lazy {
        Handler()
    }


    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, ConnectActivity::class.java)
            activity.startActivity(intent)
            activity.overridePendingTransition(0, 0)
        }
    }

    /**
     * Maintain the order of calls inside this method
     * */
    override fun onCreate(savedInstanceState: Bundle?) {
        LibraryCore.getInstance().dispatchingAndroidInjector.inject(this)
        this.setOrientation()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_gateway_connect)
        initObservers()
        inits()
        viewModel.tweetConfigs
        viewModel.uiConfigs
        viewModel.getBrokerConfigs()
        processTransaction()

    }

    private fun initObservers() {
        viewModel.transactionPollingStatusLiveData.observe(this, Observer {
            it.data?.let {
                if ( it.data?.transaction?.status != SdkConstants.CompletionStatus.INITIALISED)
                {
                    viewModel.setGatewayTransactionStatus(
                        false,
                        SmallcaseGatewaySdk.Result.ERROR,
                        null,
                        SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.code,
                        SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.error
                    )
                    finish()

                }else if (it.data.transaction.expired == true)
                {
                    viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.error,SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.code)
                    viewModel.setGatewayTransactionStatus(
                        false,
                        SmallcaseGatewaySdk.Result.ERROR,
                        null,
                        SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.code,
                        SdkConstants.ErrorMap.TRANSACTION_EXPIRED_BEFORE.error
                    )
                    finish()
                }else
                {
                    viewModel.setCurrentIntent(it.data.transaction.intent)
                    when (it.data.transaction.intent) {
                        SdkConstants.TransactionIntent.TRANSACTION -> {
                            viewModel.broker?.let {
                                checkIfMarketIsOpen()
                            } ?: proceedWithTheTransaction()
                        }
                        SdkConstants.TransactionIntent.CONNECT -> {
                            if (viewModel.isConnectedUser) launchConnectedUser()
                            else proceedWithTheTransaction()
                        }
                        else -> {
                            proceedWithTheTransaction()
                        }
                    }
                }
            }

            if (it.status == Status.ERROR) finish()
        })

        viewModel.checkIfMarketIsOpenLiveData.observe(this, Observer {
            it.data?.let {
                if (it.data?.marketOpen == true || (it.data?.amoActive == true && viewModel.isAmoEnabled)) {
                    proceedWithTheTransaction()
                } else {
                    viewModel.broker?.let {
                        viewModel.updateBrokerInDb(it)
                    }
                    viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.error,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.code)
                    viewModel.setGatewayTransactionStatus(
                        false,
                        SmallcaseGatewaySdk.Result.ERROR,
                        null,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.code,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.error
                    ).also { finish() }
                }
            }


            if (it.status == Status.ERROR) finish()
        })
    }

    /**
     * If transaction ID is null or empty assume a connected user request and simply return the connected
     * user data, this a fallback measure not a functionality
     *
     * */
    private fun processTransaction() {
        viewModel.updateDeviceType()
        // TRANX ID'S WILL BE NULL IN CASE OF CONNECTED USER, IN THAT CASE REDIRECT WITH CONNECT USER DATA
        // REMOVE THIS IF and else in release builds
        // Log.i("ConnectAct","tranx requested for ${ApiFactory.repository.getTransactionId()}")

        when {
            viewModel.transactionId.isEmpty() -> {
                if (viewModel.isConnectedUser) launchConnectedUser()
                else proceedWithTheTransaction()
            }
            else -> {
                // if the user is a guest user, he wont have broker name, if he is connected then provide broker name
                /**
                 * If the user was connected, fetch his broker and since it will be only
                 * one,we can skip the broker chooser and directly launch the flow for the
                 * already connected broker,
                 * we also need to check if the market is open currently for this broker
                 * If the user is GUEST and has no connected broker, then simply proceed to broker chooser
                 *
                 * */
                viewModel.getTransactionPoolingStatus()
            }


        }

    }

    private fun launchConnectedUser() {
        /**
         * If connect intent is found and user is already a connected user in SDK then end the flow here and
         * return the existing user data
         * */
        viewModel.setGatewayTransactionStatus(
            true,
            SmallcaseGatewaySdk.Result.CONNECT,
            viewModel.getGatewayAuthToken,
            null,
            null
        )
        finish()
    }


    /**
     * Pre-connect values are fetched from copy config and set accordingly
     * if show flag is false then dont show the view instead show the loader
     * */
    private fun inits() {
        if (viewModel.preBrokerChooserConfigs?.show == true) {
            ll_gateway_connect_popup.visibility = View.VISIBLE

            ll_gateway_connect_loader.visibility = View.GONE

            tv_gateway_connect_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(viewModel.preBrokerChooserConfigs?.title ?: "")
            tv_gateway_connect_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(viewModel.preBrokerChooserConfigs?.subTitle ?: "")
        } else {
            viewModel.setLoaderLottie(lottie_view_gateway_connect_loader)
            ll_gateway_connect_popup.visibility = View.GONE
            ll_gateway_connect_loader.visibility = View.VISIBLE
        }
    }

    private fun launchBrokerChooser() {
        BrokerChooserActivity.start(this)
        this.finish()
    }

    /**
     * If transaction request was of TRANSACTION intent then allow it only during market hours
     * */
    private fun checkIfMarketIsOpen() {
        // if the market or amo is open then proceed with transaction else pass back market is closed error
        viewModel.getMarketIsOpen(viewModel.broker!!)
    }

    /**
     * If the pre-connect screen is to be shown, then show it for 3 seconds else move ahead directly
     * */
    private fun proceedWithTheTransaction() {
        if (viewModel.preBrokerChooserConfigs?.show == true) {
            handler.postDelayed({ launchBrokerChooser() }, 3 * 1000)
        } else {
            launchBrokerChooser()
        }
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacksAndMessages(null)
    }

    override fun onBackPressed() {
        viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.error,SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER.code)
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
