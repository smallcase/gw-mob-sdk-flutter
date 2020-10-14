package com.smallcase.gateway.screens.leadgen.activity

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.*
import android.graphics.Color
import android.net.Uri
import android.net.http.SslError
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.util.Log
import android.view.View
import android.webkit.*
import android.webkit.WebView
import android.webkit.WebView.WebViewTransport
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.smallcase.gateway.R
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.leadgen.viewModel.LeadGenViewModel
import kotlinx.android.synthetic.main.activity_lead_gen.*
import javax.inject.Inject


class LeadGenActivity : AppCompatActivity() {

    @Inject
    lateinit var viewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(
            this,
            viewModelFactory
        )[LeadGenViewModel::class.java]
    }

    private var params:HashMap<String,String>? = null


    companion object {
        private const val LEAD_GEN_PARAMS = "lead_gen_params"
        fun openLeadGen(activity: Activity,params:HashMap<String,String>?)
        {
            val intent = Intent(activity,
                LeadGenActivity::class.java)
            params?.let { intent.putExtra(LEAD_GEN_PARAMS,params) }
            activity.startActivity(intent)
            activity.overridePendingTransition(0, 0)
        }
    }

    private val handler by lazy {
        Handler()
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        LibraryCore.getInstance().dispatchingAndroidInjector.inject(this)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_lead_gen)
        WebView.setWebContentsDebuggingEnabled(true)
       params = intent.getSerializableExtra(LEAD_GEN_PARAMS) as HashMap<String, String>?
       openWebView()


    }


    @SuppressLint("SetJavaScriptEnabled")
    private fun openWebView()
    {
        wv_leadGenActivity_webView.apply {
            // enable JavaScript
            settings.javaScriptEnabled = true

            // allow page to persist client-side data
            settings.domStorageEnabled = true

            // enable database storage API
            settings.databaseEnabled = true

            // allow opening new windows using JavaScript
            settings.javaScriptCanOpenWindowsAutomatically = true

            // allow webview to have multiple windows
            settings.setSupportMultipleWindows(true)

            //set transperant background
            setBackgroundColor(Color.TRANSPARENT)
            //remove in production
            WebView.setWebContentsDebuggingEnabled(true)

            webChromeClient = object : WebChromeClient() {

                override fun onCreateWindow(
                    view: WebView,
                    dialog: Boolean,
                    userGesture: Boolean,
                    resultMsg: Message?
                ): Boolean {
                    val newWebView = WebView(view.context)
                    newWebView.webViewClient = object : WebViewClient() {
                        override fun shouldOverrideUrlLoading(
                            view: WebView,
                            url: String
                        ): Boolean {
                            val browserIntent =
                                Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            startActivity(browserIntent)
                            return true
                        }
                    }
                    val transport = resultMsg!!.obj as WebViewTransport
                    transport.webView = newWebView
                    resultMsg.sendToTarget()
                    return true
                }

            }

            addJavascriptInterface(
                WebAppInterface(
                    this@LeadGenActivity
                ),"AndroidBridge")
            webViewClient = object: WebViewClient() {

                /**
                 * continue loading the page even if Ssl error occurs. This is just for dev and
                 * not meant to be used in production
                 */
                override fun onReceivedSslError(view: WebView?, handler: SslErrorHandler?, error: SslError?) {
                    handler?.proceed()
                }

                override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                    return super.shouldOverrideUrlLoading(view, url)
                }

                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    // allow the webview to continue loading a new page

                    request?.requestHeaders?.forEach {
                        Log.e("godlog","${it.key} ${it.value}")
                    }
                    if (request?.url.toString().startsWith("tel:")) {
                        val intent = Intent(Intent.ACTION_DIAL, Uri.parse(request?.url.toString()))
                        startActivity(intent)
                        return true
                    } else if (request?.url.toString().startsWith("http:") || request?.url.toString().startsWith("https:")) {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(request?.url.toString()))
                        startActivity(intent)
                        return true
                    } else if (request?.url.toString().startsWith("mailto:")) {
                        val emailIntent = Intent(Intent.ACTION_SENDTO)
                        emailIntent.data = Uri.parse(request?.url.toString())
                        return true
                    }
                    return false
                }

                override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                    super.onReceivedError(view, request, error)
                    // log any errors in page loading

                }

                override fun onPageCommitVisible(view: WebView?, url: String?) {
                    super.onPageCommitVisible(view, url)
                    handler.postDelayed({
                        lav_leadGenActivity_webviewLoader.visibility = View.GONE
                    },2000)


                }


            }
        }.also {
            //
            it.loadUrl(viewModel.getWebViewUrl(params))
        }
        val cookieManager = CookieManager.getInstance()
        cookieManager.setAcceptCookie(true)
        if (wv_leadGenActivity_webView != null)
            cookieManager.setAcceptThirdPartyCookies(wv_leadGenActivity_webView, true)

    }

    /** Instantiate the interface and set the context  */
    inner class WebAppInterface(private val mContext: Context) {

        /** Close web view and give control back  */
        @JavascriptInterface
        fun closeWebView(){
            viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.error,SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.code)
            viewModel.setGatewayTransactionStatus(false,
                SmallcaseGatewaySdk.Result.ERROR,
                null,
            SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.code,
            SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.error)
            finish()
        }

        @JavascriptInterface
        fun openThirdPartyUrl(url:String){
            Log.e("1234",url)
            val i = Intent(Intent.ACTION_VIEW)
            i.data = Uri.parse(url)
//            val shareAction = "com.smallcase.gateway.share.SHARE_ACTION"
//            val receiver = Intent(shareAction)
//            receiver.putExtra("test","test")
//            val pendingIntent = PendingIntent.getBroadcast(this@LeadGenActivity,0,receiver,PendingIntent.FLAG_UPDATE_CURRENT)
//            registerReceiver(receiver,IntentFilter(shareAction))
            startActivity(i).also { closeWebView() }
        }



    }

    val receiver = object:BroadcastReceiver(){
        override fun onReceive(context: Context?, intent: Intent?) {
            context?.unregisterReceiver(this)
            val component = intent?.getParcelableExtra<ComponentName>(Intent.EXTRA_CHOSEN_COMPONENT)
        }
    }


    override fun onBackPressed() {
        if (wv_leadGenActivity_webView.canGoBack()) {
            wv_leadGenActivity_webView.goBack()
        } else {
            viewModel.markTransactionAsErrored(SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.error,SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.code)
            viewModel.setGatewayTransactionStatus(false,
                SmallcaseGatewaySdk.Result.ERROR,
                null,
                SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.code,
                SdkConstants.ErrorMap.SIGNUP_OTHER_BROKER.error)
            finish()
        }
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacksAndMessages(null)
        this.overridePendingTransition(0,0)
    }
}