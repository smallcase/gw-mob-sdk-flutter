package com.smallcase.gateway.screens.connect.activity

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.view.animation.DecelerateInterpolator
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.core.widget.addTextChangedListener
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import coil.api.load
import com.smallcase.gateway.BuildConfig
import com.smallcase.gateway.R
import com.smallcase.gateway.base.Session.Global
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.data.adapters.BrokerGridAdapter
import com.smallcase.gateway.data.adapters.BrokerYetToComeAdapter
import com.smallcase.gateway.data.adapters.OtherBrokerAdapter
import com.smallcase.gateway.data.adapters.SearchBrokerAdapter
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.tweetConfig.UpcomingBroker
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.extensions.setOrientation
import com.smallcase.gateway.network.Status
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.connect.viewModel.ConnectActivityViewModel
import com.smallcase.gateway.screens.leadgen.activity.LeadGenActivity
import com.smallcase.gateway.screens.transaction.activity.TransactionProcessActivity
import com.smallcase.gateway.utils.*
import kotlinx.android.synthetic.main.activity_broker_chooser.*
import java.net.URLEncoder
import javax.inject.Inject

class BrokerChooserActivity :AppCompatActivity(),AdapterView.OnItemSelectedListener {

    @Inject
    lateinit var viewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(
            this,
            viewModelFactory
        )[ConnectActivityViewModel::class.java]
    }

    private lateinit var brokerGridAdapter: BrokerGridAdapter

    private lateinit var popupWindow: PopupWindow

    private lateinit var selectedUpCommingBroker:UpcomingBroker

    private lateinit var searchRecyclerViewAdapter:SearchBrokerAdapter

    private val searchList:ArrayList<Any> by lazy {
        ArrayList<Any>()
    }



    private val handler by lazy { Handler() }


    companion object {
        const val styleTagOpening = "<style>"
        const val styleTagClosing = "</style>"
        fun start(activity: Activity) {
            val intent = Intent(activity, BrokerChooserActivity::class.java)
            activity.startActivity(intent)
            activity.overridePendingTransition(0, 0)
        }
    }


    override fun onPause() {
        super.onPause()
        handler.removeCallbacksAndMessages(null)
        this.overridePendingTransition(0,0)
    }

    /**
     * Maintain the flow of methods here
     *
     * */
    override fun onCreate(savedInstanceState: Bundle?) {
        LibraryCore.getInstance().dispatchingAndroidInjector.inject(this)
        this.setOrientation()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_broker_chooser)

        initObserver()

        inits()

        generateBrookerChooser()

        animateBrokerChooserIntoView()
        selectMoreBrokerContainer()

    }

    private fun initObserver()
    {
       viewModel.transactionPollingStatusLiveData.observe(this, Observer {
           it.data?.let {
               viewModel.intent=it.data?.transaction?.intent?:""
               if (it.data?.transaction?.intent == SdkConstants.TransactionIntent.TRANSACTION)
               {
                   checkIfMarketIsOpen()
               }else proceedWithTheTransaction()
           }
           if (it.status==Status.ERROR) finish()
       })

        viewModel.checkIfMarketIsOpenLiveData.observe(this, Observer {
            it.data?.let {
                if (it.data?.marketOpen == true || (it.data?.amoActive == true && viewModel.isAmoEnabled)) proceedWithTheTransaction()
                else {
                    viewModel.currentlySelectBroker?.broker?.let {
                        viewModel.updateBrokerInDb(it)
                    }
                    viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.error,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.code)
                    viewModel.setGatewayTransactionStatus(false,
                        SmallcaseGatewaySdk.Result.ERROR,
                        null,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.code,
                        SdkConstants.ErrorMap.MARKET_CLOSED_ERROR.error)
                    finish()
                }
            }
            if (it.status==Status.ERROR) finish()
        })
    }


    private fun animateBrokerChooserIntoView() {
        ll_broker_chooser_frame.startAnimation(AnimationUtils.loadAnimation(this, R.anim.slide_in_up))
    }

    private fun generateBrookerChooser() {
        when
        {
            (viewModel.toBeShownBrokersList.size == 1)->launchBrokerPageFor(viewModel.toBeShownBrokersList[0])
            (viewModel.toBeShownBrokersList.isEmpty())->{
                viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.NO_BROKER_ERROR.error,SdkConstants.ErrorMap.NO_BROKER_ERROR.code)
                viewModel.setGatewayTransactionStatus(
                    false,
                    SmallcaseGatewaySdk.Result.ERROR,
                    null,
                    SdkConstants.ErrorMap.NO_BROKER_ERROR.code,
                    SdkConstants.ErrorMap.NO_BROKER_ERROR.error
                )
                finish()
            }
            else->setUpGridView()
        }
    }

    private fun setUpGridView()
    {
        ll_broker_chooser.visibility = View.VISIBLE

          brokerGridAdapter=  BrokerGridAdapter(
                viewModel.toBeShownBrokersList
            ){
                launchBrokerPageFor(it)
            }
        gv_broker_chooser.adapter = brokerGridAdapter
        if (viewModel.toBeShownBrokersList.size==2)
        {
            gv_broker_chooser.layoutManager = GridLayoutManager(this,2)
            gv_broker_chooser.addItemDecoration(GridDividerItemDecoration(resources.getDrawable(R.drawable.grid_horizontal_divider,theme),
                resources.getDrawable(R.drawable.grid_vertical_divider,theme),2))
        } else
        {
            gv_broker_chooser.layoutManager = GridLayoutManager(this,3)
            gv_broker_chooser.addItemDecoration(GridDividerItemDecoration(resources.getDrawable(R.drawable.grid_horizontal_divider,theme),
                resources.getDrawable(R.drawable.grid_vertical_divider,theme),3))
        }
        Log.e("mytagef",(viewModel.toBeShownBrokersList.size + viewModel.brokersShownInOptions.size).toString())
        ll_more_broker_parentContainer.visibility = if (viewModel.connectConfigs?.showTweet == true || (viewModel.toBeShownBrokersList.size + viewModel.brokersShownInOptions.size) > 9)
        {
            View.VISIBLE
        }else { View.GONE }


    }

    private fun selectMoreBrokerContainer()
    {
        ll_select_broker_container.setOnClickListener {
            setupPopupView()
        }
    }

    private fun setupPopupView(){
        ll_select_broker_container.isSelected = true
        val view = LayoutInflater.from(this).inflate(R.layout.more_broker_popup,null)
        val otherBrokerHeader = view.findViewById<TextView>(R.id.tv_other_broker_header)
        val otherBrokerRecyclerView = view.findViewById<RecyclerView>(R.id.rv_other_broker)
        val brokerYetToComeHeader = view.findViewById<TextView>(R.id.tv_broker_yet_to_come_header)
        val brokerYetToComeRecyclerView = view.findViewById<RecyclerView>(R.id.rv_broker_yet_to_come)
        val searchText = view.findViewById<EditText>(R.id.et_search_broker)
        val searchHeader = view.findViewById<TextView>(R.id.tv_search_Result)
        val searchRecyclerView = view.findViewById<RecyclerView>(R.id.rv_search_result)
        val clearText = view.findViewById<ImageView>(R.id.iv_clear_search)
        val txtSeparator = view.findViewById<View>(R.id.v_spinner_top_separator)

        searchText.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) txtSeparator.setBackgroundColor(ContextCompat.getColor(this,R.color.linkColor))
            else txtSeparator.setBackgroundColor(ContextCompat.getColor(this,R.color.separator_color))
        }

        if (viewModel.brokersShownInOptions.isNotEmpty() )
        {
            otherBrokerRecyclerView.adapter = OtherBrokerAdapter(viewModel.brokersShownInOptions){
                if (::popupWindow.isInitialized && popupWindow.isShowing)
                    popupWindow.dismiss()
                launchBrokerPageFor(it)
            }
            otherBrokerRecyclerView.layoutManager = LinearLayoutManager(this)
        }else
        {
            otherBrokerHeader.visibility=View.GONE
            otherBrokerRecyclerView.visibility = View.GONE
        }

        if (viewModel.tweetConfigs.isNotEmpty() && viewModel.connectConfigs?.showTweet == true)
        {
            brokerYetToComeRecyclerView.adapter = BrokerYetToComeAdapter(viewModel.tweetConfigs,if (::selectedUpCommingBroker.isInitialized) selectedUpCommingBroker else null,ContextCompat.getColor(this,R.color.linkColor),ResourcesCompat.getFont(this,R.font.graphikapp_medium)) {
                if (::popupWindow.isInitialized && popupWindow.isShowing)
                    popupWindow.dismiss()
                displayUpcommingBrokers(it)
            }
            brokerYetToComeRecyclerView.layoutManager = LinearLayoutManager(this)
        } else
        {
            brokerYetToComeHeader.visibility = View.GONE
            brokerYetToComeRecyclerView.visibility = View.GONE
        }
        clearText.setOnClickListener {
            searchText.text.clear()
        }
        searchRecyclerViewAdapter = SearchBrokerAdapter(searchList){
            if (::popupWindow.isInitialized && popupWindow.isShowing)
                popupWindow.dismiss()
            if (it is UpcomingBroker) displayUpcommingBrokers(it)
            else launchBrokerPageFor(it as BrokerConfig)
        }
        searchRecyclerView.adapter =searchRecyclerViewAdapter
        searchRecyclerView.layoutManager = LinearLayoutManager(this)
        searchText.addTextChangedListener { text->
            if (!text.isNullOrEmpty() && !text.isNullOrBlank())
            {
                searchList.clear()
                searchList.addAll(viewModel.brokersShownInOptions.filter { it.brokerDisplayName?.contains(text,true) == true})
                if (viewModel.connectConfigs?.showTweet == true)
                searchList.addAll(viewModel.tweetConfigs.filter { it.brokerDisplayName.contains(text,true) })
                if (::searchRecyclerViewAdapter.isInitialized)
                    searchRecyclerViewAdapter.notifyDataSetChanged()
                searchHeader.text = if (searchList.size == 0)
                {
                     getString(R.string.no_brokers_found)
                }else
                {
                   getString(R.string.results)
                }
                otherBrokerHeader.visibility = View.GONE
                otherBrokerRecyclerView.visibility = View.GONE
                brokerYetToComeHeader.visibility =View.GONE
                brokerYetToComeRecyclerView.visibility = View.GONE
                searchHeader.visibility = View.VISIBLE
                searchRecyclerView.visibility = View.VISIBLE
                clearText.visibility = View.VISIBLE
            }else
            {
                otherBrokerHeader.visibility = if (viewModel.brokersShownInOptions.isNotEmpty()) View.VISIBLE else View.GONE
                otherBrokerRecyclerView.visibility = if (viewModel.brokersShownInOptions.isNotEmpty()) View.VISIBLE else View.GONE
                brokerYetToComeHeader.visibility = if (viewModel.tweetConfigs.isNotEmpty()) View.VISIBLE else View.GONE
                brokerYetToComeRecyclerView.visibility = if (viewModel.tweetConfigs.isNotEmpty()) View.VISIBLE else View.GONE
                searchHeader.visibility = View.GONE
                searchRecyclerView.visibility = View.GONE
                clearText.visibility = View.GONE
                searchList.clear()
            }
        }

        popupWindow = PopupWindow(view, ll_select_broker_container.width,WindowManager.LayoutParams.WRAP_CONTENT)
        popupWindow.setOnDismissListener {
            ll_select_broker_container.isSelected = false
            searchList.clear() }
        popupWindow.isFocusable = true
        popupWindow.elevation = 20f
        popupWindow.animationStyle = R.style.popup_animation
        popupWindow.showAsDropDown(ll_select_broker_container,0,-(ll_select_broker_container.height + convertDpToPixel(260)))

    }

    private fun displayUpcommingBrokers(upcomingBrokers:UpcomingBroker)
    {
        selectedUpCommingBroker = upcomingBrokers
        cv_tweet_container.visibility=View.VISIBLE
        broker_i.visibility = View.VISIBLE
        tv_broker_name.typeface = ResourcesCompat.getFont(this,R.font.graphikapp_medium)
        tv_broker_name.setTextColor(ContextCompat.getColor(this,R.color.selected_other_broker_text_color))
        iv_popup_ico.setImageResource(R.drawable.ic_expand_less_grey)
        tv_broker_name.text = upcomingBrokers.brokerDisplayName
        broker_i.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${upcomingBrokers.broker}.png") {
            crossfade(true)
        }

    }

    private fun inits() {

        val configs = viewModel.connectConfigs
        tv_broker_chooser_title_tv.text = viewModel.processConfigBasedUiStringLocally(configs?.title ?: "")
        tv_broker_chooser_message_tv.text = viewModel.processConfigBasedUiStringLocally(configs?.subTitle ?: "")

        iv_broker_chooser_close_bt.setOnClickListener {
            markError(SdkConstants.ErrorMap.CLOSED_BROKER_CHOOSER)
        }
        tv_broker_chooser_signup_bt.setOnClickListener {
            LeadGenActivity.openLeadGen(this,null)
            finish()
//            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("http://www.smallcase.com/signup?utm_source=${viewModel.currentGateway}&utm_medium=gateway&utm_content=brokerChooser&utm_campaign=android"))
//            startActivity(browserIntent).also { markError(SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER) }
        }

        /**
         * CLicking on this title for 10 times switches on the LEPRECHAUN MODE
         * Not a functionality ,just a hack for testing
         * */
        tv_broker_chooser_title_tv.setOnClickListener {
            viewModel.handleLeprechaunMode { Toast.makeText(
                this,
                "${Global.LEPRECHAUN} mode switched on",
                Toast.LENGTH_SHORT
            ).show() }
        }
        cv_tweet_container.setOnClickListener {
            if (::selectedUpCommingBroker.isInitialized)
            {
                openTwitter(viewModel.processTwitterHandleText(viewModel.connectConfigs?.tweetMessage ?: "Hey @<BROKER_TWEET_HANDLE>, when will you start offering smallcases? @smallcaseHQ #startwithsmallcase", selectedUpCommingBroker.twitterHandle)).also { markError(SdkConstants.ErrorMap.OTHER_BROKER) }
            }

        }
    }

    private fun markError(errorMap:SdkConstants.ErrorMap){
        viewModel.markTransactionAsErrored(errorMap.error,errorMap.code)
        viewModel.setGatewayTransactionStatus(
            false,
            SmallcaseGatewaySdk.Result.ERROR,
            null,errorMap.code,errorMap.error
        )
        finish()
    }
    private fun openTwitter(tweet:String)
    {
        val tweetIntent = Intent(Intent.ACTION_SEND)
        tweetIntent.putExtra(Intent.EXTRA_TEXT, tweet)
        tweetIntent.type = "text/plain"

        val packManager: PackageManager = packageManager
        val resolvedInfoList: List<ResolveInfo> =
            packManager.queryIntentActivities(tweetIntent, PackageManager.MATCH_DEFAULT_ONLY)

        var resolved = false
        for (resolveInfo in resolvedInfoList) {
            if (resolveInfo.activityInfo.packageName.startsWith("com.twitter.android")) {
                tweetIntent.setClassName(
                    resolveInfo.activityInfo.packageName,
                    resolveInfo.activityInfo.name
                )
                resolved = true
                break
            }
        }
        if (resolved) {
            startActivity(tweetIntent)
        } else {
             startActivity(Intent(
                 Intent.ACTION_VIEW,
                 Uri.parse("https://twitter.com/intent/tweet?text=${URLEncoder.encode(tweet, "utf-8")}")
             ))
        }
    }

    /**
     * Fetches end url string for Iframe brokers case
     * */
    private fun getRemoteBrokerParamsUrl() {

        viewModel.getBrokerParamsUrl.observe(this, Observer {
            it.data?.let {
                launchFlow()}
            if(it.status == Status.ERROR)
                finish()
        })
    }

    /**
     * Launch the flow for the requested broker
     * also set the request broker currently as primary into the repo by calling setTargetBroker()
     * */
    private fun launchBrokerPageFor(brokerConfig: BrokerConfig) {

        viewModel.currentlySelectBroker = brokerConfig
        viewModel.currentlySelectBroker?.broker?.let {
            Log.e("mytag","updateBroker")
            viewModel.updateBrokerInDb(it) }
        if (brokerConfig.gatewayLoginConsent!=null && viewModel.connectedUserDataModel==null && viewModel.toBeShownBrokersList.size!=1)
        {
            if (::brokerGridAdapter.isInitialized)
                brokerGridAdapter.setSelected(brokerConfig)
            val moreBrokerContainerHeight = ll_more_broker_parentContainer.measuredHeight
            val increasedHeight = getHeight(this,brokerConfig.gatewayLoginConsent.replace(styleTagOpening,"").replace(styleTagClosing,""),12,getScreenWidth() - 48,ResourcesCompat.getFont(this.applicationContext,R.font.graphikapp_medium)!!,0) + 210
            ll_more_broker_parentContainer.visibility = View.GONE
            val newParams = ll_broker_chooser_consent_container.layoutParams
            newParams.height = moreBrokerContainerHeight
            ll_broker_chooser_consent_container.layoutParams = newParams
            ll_broker_chooser_consent_container.alpha = 0f
            button_giveConsent.alpha = 0f
            tv_broker_chooser_consentTxt.alpha = 0f

            ll_broker_chooser_consent_container.visibility = View.VISIBLE

            val params = ll_broker_chooser_consent_container.layoutParams
            params.height = increasedHeight
            ll_broker_chooser_consent_container.layoutParams = params
            handler.postDelayed({
                ll_broker_chooser_consent_container.animate().alpha(1.0f).setDuration(300).setInterpolator(DecelerateInterpolator()).start()
                button_giveConsent.animate().alpha(1.0f).setDuration(300).setInterpolator(DecelerateInterpolator()).start()
                tv_broker_chooser_consentTxt.animate().alpha(1.0f).setDuration(300).setInterpolator(DecelerateInterpolator()).start()
            },200)
            tv_broker_chooser_consentTxt.setText(makeSpannable(viewModel.processConfigBasedUiStringLocally(brokerConfig.gatewayLoginConsent),"\\$styleTagOpening.*?\\$styleTagClosing",styleTagOpening,styleTagClosing))
            button_giveConsent.text = "Continue with ${brokerConfig.brokerShortName}"
            button_giveConsent.setOnClickListener {
                viewModel.updateConsent()
                launch(brokerConfig) }

        } else
        {
            launch(brokerConfig)
        }
    }





    

    private fun launch(brokerConfig: BrokerConfig){
        viewModel.launchBrokerPageFor(brokerConfig,BuildConfig.VERSION_NAME).also { urlParam->
            /**
             * If the broker is of Iframe category and the leprechaun mode is OFF
             * */
            if (brokerConfig.isIframePlatform && !viewModel.isLeprechaunConnected)
                getRemoteBrokerParamsUrl()
            else
                launchFlow()
        }
    }

    /**
     *
     * */
    private fun launchFlow() {
//        Log.i("SDK_LOGS","LAUNCH URL is $WEB_URL_TO_LAUNCH")
       viewModel.getTransactionPoolingStatus()
    }

    private fun proceedWithTheTransaction() {
        // close this page
        // Log.i("BrokerChooser", WEB_URL_TO_LAUNCH)

        if ((viewModel.connectedUserDataModel != null && viewModel.currentlySelectBroker?.gatewayLoginConsent != null && viewModel.currentlySelectBroker != null) ||
            (viewModel.connectedUserDataModel == null && viewModel.currentlySelectBroker?.gatewayLoginConsent != null && viewModel.toBeShownBrokersList.size == 1))
        {
            ConnectedConsentActivity.launch(
                this@BrokerChooserActivity,
                viewModel.WEB_URL_TO_LAUNCH,
                viewModel.intent,
                viewModel.currentlySelectBroker!!
            )
        } else
        {
            TransactionProcessActivity.launch(
                this@BrokerChooserActivity,
                viewModel.WEB_URL_TO_LAUNCH,
                viewModel.intent
            )
        }

        this@BrokerChooserActivity.finish()
    }

    private fun checkIfMarketIsOpen() {
        // if the market or amo is open then proceed with transaction else pass back market is closed error
        viewModel.getMarketIsOpen(viewModel.broker?: viewModel.currentlySelectBroker?.broker?: "")

    }

    override fun onNothingSelected(parent: AdapterView<*>?) {

    }

    override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
       Toast.makeText(this,viewModel.brokersShownInOptions[position].brokerDisplayName,Toast.LENGTH_SHORT).show()
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
