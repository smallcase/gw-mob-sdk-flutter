package com.smallcase.gateway.screens.transaction.activity

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.text.Spannable
import android.text.SpannableString
import android.text.Spanned
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.browser.customtabs.*
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.internal.LinkedTreeMap
import com.smallcase.gateway.R
import com.smallcase.gateway.base.helpers.PackageHelper
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.listeners.DataListener
import com.smallcase.gateway.data.models.BaseReponseDataModel
import com.smallcase.gateway.data.models.HoldingsImportSuccess
import com.smallcase.gateway.data.models.InitialisationResponse
import com.smallcase.gateway.data.models.TransactionPollStatusResponse
import com.smallcase.gateway.data.models.TransactionProcessingModel.Data
import com.smallcase.gateway.data.requests.InitRequest
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.enums.PollTransactionStatus
import com.smallcase.gateway.extensions.setOrientation
import com.smallcase.gateway.network.Resource
import com.smallcase.gateway.network.Status
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.transaction.viewModel.TransactionActivityViewModel
import com.smallcase.gateway.utils.getError
import dagger.android.support.DaggerAppCompatActivity
import kotlinx.android.synthetic.main.activity_transaction_process.*
import org.json.JSONObject
import javax.inject.Inject

class TransactionProcessActivity : AppCompatActivity() {

    @Inject
    lateinit var appViewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(this, appViewModelFactory)[TransactionActivityViewModel::class.java]
    }

    private var webUrlPackage: String? = null


    private var mCustomTabsSession: CustomTabsSession? = null
    private var mCustomTabsServiceConnection: CustomTabsServiceConnection? = null
    //private var CHROME_TAB_STATUS = -1


    lateinit var waitingForChromeInitCountDownTimer: CountDownTimer

    private var completionStatus = ""
    //private var errorMessage = ""
    private var errorMsg = ""
    private var errorCode = -1

    var pollAttempted = 0
    val pollTimeInterval = 2000
    val pollForTransaction = 3
    val pollForHoldingImport = 15

    private var onNewIntent = false

    private val handler by lazy {
        Handler()
    }

    companion object {
        const val INTENT_TYPE = "intentType"
        const val URL = "url"
        const val SHOW_CONNECTED = "showConnected"
        fun launch(activity: Activity, url: String, intentType: String) {
            val intent = Intent(activity, TransactionProcessActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.putExtra(URL, url)
            intent.putExtra(INTENT_TYPE, intentType)
            activity.startActivity(intent)
        }
    }

    private val cancelIntentBasedStatusObserver by lazy {
        Observer<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> {
            it.data?.let { response ->
                when {
                    ((response.data?.transaction?.error?.value == true) || (response.data?.transaction?.status == SdkConstants.CompletionStatus.COMPLETED)) ->
                        getTransactionStatus()
                    ((response.data?.transaction?.status == SdkConstants.CompletionStatus.INITIALISED) || (response.data?.transaction?.status == SdkConstants.CompletionStatus.USED)) ->
                        viewModel.markTransacTionAsCancelled()

                    (response.data?.transaction?.intent == SdkConstants.TransactionIntent.TRANSACTION && response.data.transaction.status == SdkConstants.CompletionStatus.PROCESSING) -> {
                        viewModel.setGatewayTransactionStatus(
                            false,
                            SmallcaseGatewaySdk.Result.ERROR,
                            null,
                            SdkConstants.ErrorMap.ORDER_IN_QUEUE.code,
                            SdkConstants.ErrorMap.ORDER_IN_QUEUE.error
                        )
                        finish()
                    }
                    else -> {
                        viewModel.setInternalErrorOccured()
                        finish()
                    }
                }
            }

            if (it.status == Status.ERROR) finish()
        }
    }


    private val actionBasedStatusListener by lazy {
        Observer<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> {
            it.data?.let { response ->
                when {
                    ((response.data?.transaction?.error?.value == true) || (response.data?.transaction?.status == SdkConstants.CompletionStatus.COMPLETED) ||
                            (response.data?.transaction?.status == SdkConstants.CompletionStatus.PROCESSING))
                    -> getTransactionStatus()
                    (response.data?.transaction?.status == SdkConstants.CompletionStatus.INITIALISED || response.data?.transaction?.status == SdkConstants.CompletionStatus.USED) -> {
                        if (completionStatus.contains(
                                SdkConstants.CompletionStatus.ERRORED,
                                true
                            ) && errorCode !=-1 && errorMsg!=""
                        ) {
                            markTransactionAsErrored(errorCode, errorMsg)
                            viewModel.setGatewayTransactionStatus(
                                false,
                                SmallcaseGatewaySdk.Result.ERROR,
                                null,
                                errorCode,
                                errorMsg
                            )
                        } else {
                            viewModel.markTransactionAsErrored(
                                if (response.data.transaction.status == SdkConstants.CompletionStatus.INITIALISED) SdkConstants.ErrorMap.CLOSED_CHROME_TAB_INITIALIZED.error
                                else SdkConstants.ErrorMap.CLOSED_CHROME_TAB_USED.error,
                                if (response.data.transaction.status == SdkConstants.CompletionStatus.INITIALISED) SdkConstants.ErrorMap.CLOSED_CHROME_TAB_INITIALIZED.code
                                else SdkConstants.ErrorMap.CLOSED_CHROME_TAB_USED.code
                            )
                            viewModel.setGatewayTransactionStatus(
                                false,
                                SmallcaseGatewaySdk.Result.ERROR,
                                null,
                                if (response.data.transaction.status == SdkConstants.CompletionStatus.INITIALISED) SdkConstants.ErrorMap.CLOSED_CHROME_TAB_INITIALIZED.code
                                else SdkConstants.ErrorMap.CLOSED_CHROME_TAB_USED.code,
                                if (response.data.transaction.status == SdkConstants.CompletionStatus.INITIALISED) SdkConstants.ErrorMap.CLOSED_CHROME_TAB_INITIALIZED.error
                                else SdkConstants.ErrorMap.CLOSED_CHROME_TAB_USED.error
                            )
                        }
                        finish()
                    }
                    else -> {
                        viewModel.setInternalErrorOccured()
                        finish()
                    }
                }
            }
            if (it.status == Status.ERROR) finish()
        }
    }


    private val statusObserver by lazy {
        Observer<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> {
            it.data?.let {
                when {
                    (it.data?.transaction?.error?.value == true) -> {
                        when {
                            (it.data.transaction.error.message!!.contains(
                                "UserMismatch",
                                true
                            )) -> showUserMismatchUI(
                                SdkConstants.ErrorMap.USER_MISMATCH.code,
                                SdkConstants.ErrorMap.USER_MISMATCH.error
                            )
                            else -> {
                                if (errorCode!=-1 && errorMsg!="")
                                {
                                    viewModel.setGatewayTransactionStatus(
                                        false,
                                        SmallcaseGatewaySdk.Result.ERROR,
                                        null,
                                        errorCode,
                                        errorMsg
                                    )
                                }else
                                {

                                    viewModel.setGatewayTransactionStatus(
                                        false,
                                        SmallcaseGatewaySdk.Result.ERROR,
                                        null,
                                        it.data.transaction.error.code,
                                        it.data.transaction.error.message
                                    )
                                }
                                finish()
                            }
                        }
                    }
                    (it.data?.transaction?.status == SdkConstants.CompletionStatus.COMPLETED) -> {
                        when (it.data.transaction.intent) {
                            SdkConstants.TransactionIntent.CONNECT -> {
                                // call init again and update user credentials
                                var smallcaseAuthToken = ""

                                try {

                                    val response =
                                        JSONObject(it.data.transaction.success.toString())

                                    smallcaseAuthToken = response.getString("smallcaseAuthToken")

                                } catch (t: Throwable) {
                                    val splited =
                                        it.data.transaction.success.toString().split(",")
                                    for (item in splited) {
                                        if (item.contains("smallcaseAuthToken=")) {
                                            smallcaseAuthToken =
                                                item.replace("smallcaseAuthToken=", "").trim()
                                            smallcaseAuthToken =
                                                smallcaseAuthToken.replace("{", "").trim()
                                            smallcaseAuthToken =
                                                smallcaseAuthToken.replace("}", "").trim()
                                            break
                                        }
                                    }
                                }


                                if (smallcaseAuthToken.isNotEmpty()) {
                                    viewModel.setSmallcaseAuthToken(smallcaseAuthToken)
                                }

                                SmallcaseGatewaySdk.init(
                                    InitRequest(
                                        viewModel.getGatewayAuthToken
                                    ),
                                    object :
                                        DataListener<InitialisationResponse> {
                                        override fun onSuccess(data: InitialisationResponse) {
                                            showUserConnectedUI()
                                        }

                                        override fun onFailure(
                                            errorCode: Int,
                                            errorMessage: String
                                        ) {
                                            // this is a special case, for case where it has been triggered twice
                                            if (errorCode != SdkConstants.ErrorCode.CHECK_VIOLETED) {
                                                viewModel.setInternalErrorOccured()
                                                finish()
                                            }
                                        }
                                    })
                            }
                            SdkConstants.TransactionIntent.TRANSACTION -> {
                                // pass the order config back to the listener
                                viewModel.setGatewayTransactionStatus(
                                    true, SmallcaseGatewaySdk.Result.TRANSACTION,
                                    Gson().toJson(it.data.transaction.success), null, null
                                )
                                finish()
                            }
                            SdkConstants.TransactionIntent.HOLDINGS_IMPORT -> {
                                showHoldingsProcessingUI()
                                handler.postDelayed(Runnable {
                                    val res=it.data.transaction.success as LinkedTreeMap<*, *>
                                    val smallcaseAuthToken=res.get("smallcaseAuthToken")
                                    val response = HoldingsImportSuccess(
                                        smallcaseAuthToken.toString(),
                                        true,
                                        it.data.transaction.transactionId
                                    )
                                    viewModel.setGatewayTransactionStatus(
                                        true,
                                        SmallcaseGatewaySdk.Result.HOLDING_IMPORT,
                                        Gson().toJson(response).also { Log.e("mytag",it) },
                                        null,
                                        null
                                    )
                                    finish()
                                },3000)

                            }
                            else -> {
                                viewModel.setInternalErrorOccured()
                                finish()
                            }
                        }
                    }
                    (it.data?.transaction?.status == SdkConstants.CompletionStatus.INITIALISED || it.data?.transaction?.status == SdkConstants.CompletionStatus.USED) -> {
                        if (completionStatus.contains(
                                SdkConstants.CompletionStatus.ERRORED,
                                true
                            )
                        ) {
                            markTransactionAsErrored(errorCode, errorMsg)
                        } else if (completionStatus.contains(
                                SdkConstants.CompletionStatus.CANCELLED,
                                true
                            )
                        ) {
                            viewModel.markTransacTionAsCancelled()
                        } else {
                            markTransactionAsErrored(
                                SdkConstants.ErrorCode.API_ERROR,
                                SdkConstants.CompletionStatus.API_ERROR
                            )
                        }
                    }
                    (it.data?.transaction?.status == SdkConstants.CompletionStatus.PROCESSING) -> {
                        when (it.data.transaction.intent) {
                            SdkConstants.TransactionIntent.CONNECT -> {
                                // connect does not having processing
                            }
                            SdkConstants.TransactionIntent.TRANSACTION -> {
                                try {
                                    val res=it.data.transaction.success as LinkedTreeMap<*, *>

                                    val resObj: Data = Gson().fromJson(Gson().toJson(res.get("data")), Data::class.java)

                                    Log.e("mytag",resObj.toString())
                                    if (resObj.batches.any { it.variety == "amo" })
                                    {
                                        viewModel.setGatewayTransactionStatus(
                                            true, SmallcaseGatewaySdk.Result.TRANSACTION,
                                            Gson().toJson(it.data.transaction.success), null, null
                                        )
                                        finish()
                                    }else
                                    {
                                        if (pollAttempted == pollForTransaction) {
                                            showOrderInQueueUI(Gson().toJson(it.data.transaction.success))
                                        } else {
                                            pollAttempted = 0
                                            handleTransactionPendingStatus(pollForTransaction)
                                        }
                                    }
                                }catch (e:Exception)
                                {
                                    if (pollAttempted == pollForTransaction) {
                                        showOrderInQueueUI(Gson().toJson(it.data.transaction.success))
                                    } else {
                                        pollAttempted = 0
                                        handleTransactionPendingStatus(pollForTransaction)
                                    }
                                }

                            }
                            SdkConstants.TransactionIntent.HOLDINGS_IMPORT -> {
                                showHoldingsProcessingUI()
                                if (pollAttempted == pollForHoldingImport) {
                                    markTransactionAsErrored(SdkConstants.ErrorMap.TIMED_OUT.code, SdkConstants.ErrorMap.TIMED_OUT.error)
                                } else {
                                    pollAttempted = 0
                                    handleTransactionPendingStatus(pollForHoldingImport)
                                }
                            }
                            else -> {
                                viewModel.setInternalErrorOccured()
                                finish()
                            }
                        }
                    }
                    else -> {
                        viewModel.setInternalErrorOccured()
                        finish()
                    }

                }

            }
            if (it.status == Status.ERROR) finish()
        }
    }

    private val transactionCancelledAndErroredObserver by lazy {
        Observer<Resource<BaseReponseDataModel<Boolean>>> {
            it.data?.let { getTransactionStatus() }

            if (it.status == Status.ERROR) {
                finish()
            }
        }
    }

    private fun initLiveDataObservers() {
        viewModel.markTransactionAsCancelledLiveData.observe(
            this,
            transactionCancelledAndErroredObserver
        )

        viewModel.markTransactionAsErroredLiveData.observe(
            this,
            transactionCancelledAndErroredObserver
        )

        viewModel.pollForTransactionStatusLiveData.observe(this, pollForTransactionStatusObserver)

        viewModel.getTransactionStatusLiveData.observe(this, statusObserver)

        viewModel.getForcedTransactionStatusLiveData.observe(this, actionBasedStatusListener)

        viewModel.getCancelTransactionStatusLiveData.observe(this, cancelIntentBasedStatusObserver)
    }

    private val pollForTransactionStatusObserver by lazy {
        Observer<Resource<BaseReponseDataModel<TransactionPollStatusResponse>>> {
            it.data?.let {
                Log.e("mytag",pollAttempted.toString())
                when {
                    (it.data?.transaction?.error?.value == true || (it.data?.transaction?.status == SdkConstants.CompletionStatus.COMPLETED)) -> getTransactionStatus()
                    ((it.data?.transaction?.status == SdkConstants.CompletionStatus.PROCESSING) || (it.data?.transaction?.status == SdkConstants.CompletionStatus.INITIALISED) || (it.data?.transaction?.status == SdkConstants.CompletionStatus.USED)) -> {
                            if (it.data.transaction.intent == SdkConstants.TransactionIntent.TRANSACTION)
                            {
                                if (pollAttempted < pollForTransaction)
                                    handleTransactionPendingStatus(pollForTransaction)
                                else getTransactionStatus()
                            }else
                            {
                                if (pollAttempted < pollForHoldingImport)
                                    handleTransactionPendingStatus(pollForHoldingImport)
                                else getTransactionStatus()
                            }


                    }
                    else -> {
                        viewModel.setInternalErrorOccured()
                        finish()
                    }
                }
            }

            if (it.status == Status.ERROR) finish()
        }
    }


    private fun handleTransactionPendingStatus(timesToPoll:Int) {
        if (pollAttempted < timesToPoll) {
            pollAttempted++
            Handler().postDelayed({ pollForTransactionStatus() }, pollTimeInterval.toLong())
        }
    }

    private fun pollForTransactionStatus() {
        viewModel.getTransactionPollingStatus(PollTransactionStatus.PollForTransactionStatus)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        LibraryCore.getInstance().dispatchingAndroidInjector.inject(this)
        setTheme(R.style.Theme_SmallcaseGateway)
        this.setOrientation()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_transaction_process)
        initLiveDataObservers()

        processUrlLaunchIntent()
    }

    private fun processUrlLaunchIntent() {
        if (intent != null && intent.extras != null) {
            if (intent.hasExtra(INTENT_TYPE)) {
                viewModel.intentType = intent?.extras?.getString(INTENT_TYPE) ?: ""
            }
            if (intent.hasExtra(URL)) {
                viewModel.WEB_URL_TO_LAUNCH = intent?.extras?.getString(URL) ?: ""

                bindCustomTabService()
            }
            if (intent.hasExtra(SHOW_CONNECTED)) {
                val showConnectedFlag = intent?.extras?.getBoolean(SHOW_CONNECTED)
                if (showConnectedFlag == true) {
                    showUserConnectedUI()
                }
            }
        }

        inits()
    }

    private fun inits() {

        val manualCheckSpan =
            SpannableString(resources.getString(R.string.manual_transaction_status_request_message))

        val clickableSpan = object : ClickableSpan() {
            override fun onClick(p0: View) {
                getForcedTransactionStatus()
            }

            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.isUnderlineText = false
            }
        }

        manualCheckSpan.setSpan(
            clickableSpan, manualCheckSpan.length - 10,
            manualCheckSpan.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        manualCheckSpan.setSpan(
            ForegroundColorSpan(
                ResourcesCompat.getColor(
                    this.resources,
                    R.color.linkColor,
                    null
                )
            ),
            manualCheckSpan.length - 10,
            manualCheckSpan.length,
            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
        )

        tv_tranx_process_loading_popup_action.movementMethod = LinkMovementMethod.getInstance()
        tv_tranx_process_loading_popup_action.highlightColor = Color.TRANSPARENT
        tv_tranx_process_loading_popup_action.text = manualCheckSpan

        viewModel.setLoaderLottie(gif_loader_tranx_process_loader)
        changeTransactionStatusVisibility(true)

        when (viewModel.intentType) {
            SdkConstants.TransactionIntent.CONNECT -> showUserConnectingUI()
            SdkConstants.TransactionIntent.TRANSACTION -> showOrderProcessingUI()
            SdkConstants.TransactionIntent.HOLDINGS_IMPORT -> {
                showUserConnectingUI()
            }
            else -> { finish() }
        }
    }


    override fun onNewIntent(newIntent: Intent?) {
        val bundle = intent.extras
        if (bundle != null) {
            for (key in bundle.keySet()) {
                Log.e(
                    "newmytag",
                    "$key : " + (bundle.get(key)?.let { "${bundle.get(key)}" } ?: "NULL"))
            }
        }

        onNewIntent = true
        processNewIntent(newIntent)
        super.onNewIntent(newIntent)


    }

    fun processNewIntent(newIntent: Intent?) {
        completionStatus = ""

        val action = newIntent?.action
        val data = newIntent?.dataString // / this gives us exact redirect uri

        if (data != null) {
            val uri =
                Uri.parse(data)
            val server = uri.authority
            val path = uri.path
            val protocol = uri.scheme
            val args = uri.queryParameterNames

            if (uri.getQueryParameter("status") != null) {
                completionStatus = uri.getQueryParameter("status")?: ""
            }
            if (uri.getQueryParameter("error") != null) {
                errorMsg = uri.getQueryParameter("error") ?: ""
            }
            if (uri.getQueryParameter("code") != null) {
                errorCode = uri.getQueryParameter("code")?.toInt() ?: -1
            }
            getForcedTransactionStatus()
        } else {
            completionStatus = "CANCELLED"
            getTransactionStatus()
        }
    }

    private fun markTransactionAsErrored(errorCode: Int, error: String) {
        viewModel.markTransactionAsErrored(error, errorCode)
    }


    private fun getTransactionStatus() {
        viewModel.getTransactionPollingStatus(PollTransactionStatus.TransactionStatus)
    }

    private fun getForcedTransactionStatus() {
        viewModel.getTransactionPollingStatus(PollTransactionStatus.ForcedTransactionStatus)

    }

    private fun launchUrl() {
        val builder = if (mCustomTabsSession != null) {
            CustomTabsIntent.Builder(mCustomTabsSession)
        } else {
            CustomTabsIntent.Builder()
        }
        builder.enableUrlBarHiding()
        builder.setToolbarColor(ContextCompat.getColor(this, R.color.colorTabPrimary))
        val backButton =
            BitmapFactory.decodeResource(getResources(), R.drawable.baseline_arrow_back_white_24dp)
        builder.setCloseButtonIcon(backButton)
        builder.setStartAnimations(this, R.anim.slide_in_right, android.R.anim.fade_out)
        builder.setExitAnimations(this, R.anim.slide_in_right, android.R.anim.fade_out)
        PackageHelper.getCustomTabPackageName(this@TransactionProcessActivity).let {
            webUrlPackage = it
            if (it != null) {
                Log.e("mytag",it)
                try {
                    if (!cancelled) {
                        builder.build().apply {
                            this.intent.`package` = it
                        }.launchUrl(
                            this,
                            Uri.parse(viewModel.WEB_URL_TO_LAUNCH).buildUpon().appendQueryParameter(
                                "warmup",
                                "true"
                            ).build()
                        ).also { Log.e("mytag",viewModel.WEB_URL_TO_LAUNCH) }
                    }
                }catch (e: Exception)
                {
                    viewModel.setGatewayTransactionStatus(
                        false,
                        SmallcaseGatewaySdk.Result.ERROR,
                        null,
                        SdkConstants.ErrorCode.NO_BROWSER_FOUND_ERROR,
                        SdkConstants.UniqueErrorCases.NO_BROWSER_FOUND
                    )
                    finish()
                }


            } else {
                viewModel.setGatewayTransactionStatus(
                    false,
                    SmallcaseGatewaySdk.Result.ERROR,
                    null,
                    SdkConstants.ErrorCode.NO_BROWSER_FOUND_ERROR,
                    SdkConstants.UniqueErrorCases.NO_BROWSER_FOUND
                )
                finish()
            }

        }
    }

    private fun bindCustomTabService() {
        mCustomTabsServiceConnection = CustomTabServiceConnectionController()

        CustomTabsClient.bindCustomTabsService(
            this@TransactionProcessActivity,
            "com.android.chrome",
            mCustomTabsServiceConnection!!
        )

        var interval = 3000 // 5 Second
        waitingForChromeInitCountDownTimer = object : CountDownTimer(interval.toLong(), 1000) {
            override fun onFinish() {
                launchUrl()
            }

            override fun onTick(p0: Long) {
                if (mCustomTabsSession != null && mCustomTabsServiceConnection != null) {

                    launchUrl()
                    waitingForChromeInitCountDownTimer.cancel()
                }
                interval -= 1000
            }
        }
        waitingForChromeInitCountDownTimer.start()
    }

    inner class CustomTabServiceConnectionController : CustomTabsServiceConnection() {

        override fun onCustomTabsServiceConnected(name: ComponentName, client: CustomTabsClient) {
            if (viewModel.WEB_URL_TO_LAUNCH.isNotBlank() && viewModel.WEB_URL_TO_LAUNCH.isNotEmpty())
                client.warmup(0L)
            mCustomTabsSession = client.newSession(object : CustomTabsCallback() {
                override fun onNavigationEvent(navigationEvent: Int, extras: Bundle?) {
                    navigationEvent.toString()
                    // CHROME_TAB_STATUS = navigationEvent
                    //handleTabClose()
                    super.onNavigationEvent(navigationEvent, extras)
                    Log.e("mytag", navigationEvent.toString())


                }
            })

        }

        override fun onServiceDisconnected(p0: ComponentName?) {
            p0?.toShortString()
            Log.e("mytag", p0.toString())
        }
    }

    override fun onResume() {
        handleTabClose()
        changeTransactionStatusVisibility(true)
        super.onResume()
    }

    private fun changeTransactionStatusVisibility(autoDetect: Boolean) {
        tv_tranx_process_loading_popup_action.visibility = if (autoDetect) {
            if (webUrlPackage != null && !webUrlPackage?.contains("chrome")!!)
                View.VISIBLE
            else View.GONE
        } else View.GONE

    }

    override fun onStop() {
        super.onStop()
    }

    private fun handleTabClose() {
        if (webUrlPackage != null && !onNewIntent) {
            // this pair occurs when chrome tab is closed only, mark transaction as errored
            // CHROME_TAB_STATUS = -1
            getForcedTransactionStatus()


        }
    }

    private var cancelled = false

    @SuppressLint("SetTextI18n")
    private fun showUserConnectingUI() {
        //iv_tranx_process_loading_closebt.visibility = View.VISIBLE
        if (viewModel.preConnectConfigs?.show == true) {
            ll_tranx_process_loading.visibility = View.VISIBLE
            ll_tranx_process_show.visibility = View.GONE
            ll_tranx_process_loader.visibility = View.GONE

            tv_tranx_process_loading_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.preConnectConfigs?.title ?: ""
                )
            //GatewayUtilHelper.processConfigBasedUiStringLocally(viewModel.preConnectConfigs.title!!)
            tv_tranx_process_loading_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.preConnectConfigs?.subTitle ?: ""
                )

            iv_tranx_process_loading_closebt.setOnClickListener {
                cancelled = true
                handleCancelTransactionButtonClick()
            }
        } else if (viewModel.preConnectConfigs == null){
            finish()
        } else {
            ll_tranx_process_loader.visibility = View.VISIBLE
        }
    }

    private fun handleCancelTransactionButtonClick() {
        viewModel.getTransactionPollingStatus(PollTransactionStatus.CancelTransactionStatus)

    }

    @SuppressLint("SetTextI18n")
    private fun showUserConnectedUI() {
        iv_tranx_process_loading_closebt.visibility = View.VISIBLE
        val configs = viewModel.postConnectConfigs
        ll_tranx_process_loader.visibility = View.GONE

        if (configs?.show == true) {
            ll_tranx_process_show.visibility = View.VISIBLE
            tv_tranx_process_show_popup_footer.visibility = View.VISIBLE
            iv_tranx_process_show_popup_closebt.visibility = View.INVISIBLE

            iv_tranx_process_show_popup_icon.setImageResource(R.drawable.success_large)
            tv_tranx_process_show_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(configs.title ?: "")
            tv_tranx_process_show_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(configs.subTitle ?: "")

            var interval = 3000; // 5 Second

            object : CountDownTimer(interval.toLong(), 1000) {
                override fun onFinish() {
                    // pass user tranxed successfully back, gateway_loader is in repository
                    viewModel.setGatewayTransactionStatus(
                        true,
                        SmallcaseGatewaySdk.Result.CONNECT,
                        viewModel.getGatewayAuthToken,
                        null,
                        null
                    )
                    runOnUiThread {
                        this@TransactionProcessActivity.finish()
                    }
                }

                override fun onTick(p0: Long) {
                    tv_tranx_process_show_popup_footer.text =
                        "Redirecting you to ${viewModel.currentGateway} in " +
                                "${interval / 1000} seconds"
                    interval -= 1000
                }
            }.start()
        } else {
            viewModel.setGatewayTransactionStatus(
                true,
                SmallcaseGatewaySdk.Result.CONNECT,
                viewModel.getGatewayAuthToken,
                null,
                null
            )
            runOnUiThread {
                this@TransactionProcessActivity.finish()
            }
        }
    }

    private fun showUserMismatchUI(code: Int, message: String) {
        iv_tranx_process_loading_closebt.visibility = View.VISIBLE
        ll_tranx_process_loader.visibility = View.GONE

        if (viewModel.loginFailedConfigs?.show == true) {

            ll_tranx_process_loading.visibility = View.GONE
            ll_tranx_process_show.visibility = View.VISIBLE
            tv_tranx_process_show_popup_footer.visibility = View.GONE
            iv_tranx_process_show_popup_closebt.visibility = View.VISIBLE

            iv_tranx_process_show_popup_icon.setImageResource(R.drawable.error_large)

            tv_tranx_process_show_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.loginFailedConfigs?.title ?: ""
                )

            tv_tranx_process_show_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.loginFailedConfigs?.wrongUser ?: ""
                )

            iv_tranx_process_show_popup_closebt.setOnClickListener {
                viewModel.markTransactionAsErrored(message,code)
                viewModel.setGatewayTransactionStatus(
                    false,
                    SmallcaseGatewaySdk.Result.ERROR,
                    null,
                    code,
                    message
                )
                finish()
            }
        } else {
            viewModel.setGatewayTransactionStatus(
                false,
                SmallcaseGatewaySdk.Result.ERROR,
                null,
                code,
                message
            )
            finish()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun showOrderProcessingUI() {


        if (viewModel.orderFlowWaitingConfigs?.show == true) {
            ll_tranx_process_loading.visibility = View.VISIBLE
            ll_tranx_process_show.visibility = View.GONE
            ll_tranx_process_loader.visibility = View.GONE

            iv_tranx_process_show_popup_icon.setImageResource(R.drawable.ic_loading_graphic)

            tv_tranx_process_loading_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.orderFlowWaitingConfigs?.title ?: ""
                )

            tv_tranx_process_loading_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.orderFlowWaitingConfigs?.subTitle ?: ""
                )

            iv_tranx_process_loading_closebt.setOnClickListener {
                cancelled = true
                handleCancelTransactionButtonClick()
            }


        } else if (viewModel.orderFlowWaitingConfigs == null) {
            finish()
        } else {
            ll_tranx_process_loader.visibility = View.VISIBLE
        }
    }

     @SuppressLint("SetTextI18n")
     private fun showHoldingsProcessingUI() {


         if (viewModel.orderFlowWaitingConfigs?.show == true) {
             ll_tranx_process_loading.visibility = View.VISIBLE
             ll_tranx_process_show.visibility = View.GONE
             ll_tranx_process_loader.visibility = View.GONE
             lav_process_loading_anim.setAnimation("holdings_loader.json")
             lav_process_loading_anim.playAnimation()
             iv_tranx_process_show_popup_icon.setImageResource(R.drawable.ic_loading_graphic)

             tv_tranx_process_loading_popup_title.text =
                 viewModel.processConfigBasedUiStringLocally(
                     viewModel.postImportHoldingsConfigs?.title ?: ""
                 )

             tv_tranx_process_loading_popup_message.text =
                 viewModel.processConfigBasedUiStringLocally(
                     viewModel.postImportHoldingsConfigs?.subTitle ?: ""
                 )

             iv_tranx_process_loading_closebt.setOnClickListener {
                 cancelled = true
                 handleCancelTransactionButtonClick()
             }


         } else if (viewModel.orderFlowWaitingConfigs == null) {
             finish()
         } else {
             ll_tranx_process_loader.visibility = View.VISIBLE
         }
     }


    private fun showOrderInQueueUI(jsonStr:String) {
        changeTransactionStatusVisibility(false)
        iv_tranx_process_loading_closebt.visibility = View.VISIBLE
        if (viewModel.orderInQueueConfigs?.show == true) {
            ll_tranx_process_loading.visibility = View.VISIBLE
            ll_tranx_process_show.visibility = View.GONE
            ll_tranx_process_loader.visibility = View.GONE
            ll_tranx_process_poweredBy.visibility = View.GONE
            lav_process_loading_anim.visibility = View.GONE
            iv_process_loading_processing.visibility = View.VISIBLE


            tv_tranx_process_loading_popup_title.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.orderInQueueConfigs?.title ?: ""
                )

            tv_tranx_process_loading_popup_message.text =
                viewModel.processConfigBasedUiStringLocally(
                    viewModel.orderInQueueConfigs?.subTitle ?: ""
                )


            iv_tranx_process_loading_closebt.setOnClickListener {
                viewModel.setGatewayTransactionStatus(
                    true, SmallcaseGatewaySdk.Result.TRANSACTION,
                    jsonStr, null, null
                )
                finish()
            }
            b_tranx_process_gotIt.visibility = View.VISIBLE
            b_tranx_process_gotIt.setOnClickListener {
                viewModel.setGatewayTransactionStatus(
                    true, SmallcaseGatewaySdk.Result.TRANSACTION,
                    jsonStr, null, null
                )
                finish()
            }
        } else if (viewModel.orderInQueueConfigs == null) {
            finish()
        } else {
            ll_tranx_process_loader.visibility = View.VISIBLE
        }
    }

    override fun onDestroy() {

        try {
            if (mCustomTabsServiceConnection != null) {
                unbindService(mCustomTabsServiceConnection!!)
                mCustomTabsServiceConnection = null
            }
            handler.removeCallbacksAndMessages(null)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        super.onDestroy()
    }

    override fun onBackPressed() {}


}
