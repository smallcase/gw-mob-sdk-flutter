package com.smallcase.gateway.screens.common

import android.graphics.BitmapFactory
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.smallcase.gateway.R
import com.smallcase.gateway.base.helpers.PackageHelper
import com.smallcase.gateway.data.SdkConstants
import com.smallcase.gateway.di.factory.AppViewModelFactory
import com.smallcase.gateway.portal.SmallcaseGatewaySdk
import com.smallcase.gateway.screens.base.BaseViewModel
import com.smallcase.gateway.screens.transaction.viewModel.TransactionActivityViewModel
import javax.inject.Inject

class RedirectActivity : AppCompatActivity() {

    @Inject
    lateinit var appViewModelFactory: AppViewModelFactory

    private val viewModel by lazy {
        ViewModelProvider(this, appViewModelFactory)[BaseViewModel::class.java]
    }

    var webUrlPackage:String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_redirect)

    }

    private fun getRedirectUrl()
    {
     intent.dataString?.let {intentUrl->
         Log.e("mytag",intentUrl)
         val uri = Uri.parse(intentUrl)
         uri.getQueryParameter("url")?.let {redirectUrl->
           launchUrl(redirectUrl)
         }
     }


    }

    private fun launchUrl(redirectUrl:String) {
        val builder = CustomTabsIntent.Builder()
        builder.enableUrlBarHiding()
        builder.setToolbarColor(ContextCompat.getColor(this, R.color.colorTabPrimary))
        val backButton =
            BitmapFactory.decodeResource(getResources(), R.drawable.baseline_arrow_back_white_24dp)
        builder.setCloseButtonIcon(backButton)
        builder.setStartAnimations(this, R.anim.slide_in_right, android.R.anim.fade_out)
        builder.setExitAnimations(this, R.anim.slide_in_right, android.R.anim.fade_out)
        PackageHelper.getCustomTabPackageName(this).let {
            webUrlPackage = it
            if (it != null) {
                Log.e("mytag",it)
                try {
                    builder.build().apply {
                        this.intent.`package` = it
                    }.launchUrl(
                        this,
                        Uri.parse(redirectUrl).buildUpon().appendQueryParameter(
                            "warmup",
                            "true"
                        ).build()
                    ).also { Log.e("mytag",redirectUrl) }
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

    override fun onBackPressed() {

    }

    override fun onResume() {
        super.onResume()
        if (webUrlPackage!=null)
        {
            finish()
        }else
        {
            getRedirectUrl()
        }
    }

}
