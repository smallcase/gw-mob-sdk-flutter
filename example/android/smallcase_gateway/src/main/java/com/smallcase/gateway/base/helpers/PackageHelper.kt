package com.smallcase.gateway.base.helpers

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.text.TextUtils
import androidx.browser.customtabs.CustomTabsService

object PackageHelper {

    /* The function first checks if user has set a default browser. If yes,
     * preference is given to it. If there is no default, find all apps that
     * can handle VIEW intents. Filter out only the packages that provide
     * custom tabs support. Preference is given to Chrome if it is present.
     * If no available browser supports custom tabs, return null
     */

    fun getCustomTabPackageName(context: Context): String? {

        val STABLE_PACKAGE = "com.android.chrome"
        val BETA_PACKAGE = "com.chrome.beta"
        val DEV_PACKAGE = "com.chrome.dev"
        val LOCAL_PACKAGE = "com.google.android.apps.chrome"

        val pm = context.packageManager
        val dummyURL =
            "http://www.example.com" // Sample URL to find apps that can handle a VIEW Intent on a URL
        val activityIntent = Intent(Intent.ACTION_VIEW, Uri.parse(dummyURL))
        val defaultViewHandlerInfo = pm.resolveActivity(activityIntent, 0)
        val defaultViewHandlerPackageName = defaultViewHandlerInfo?.activityInfo?.packageName

        // Get all apps that can handle VIEW intents.

        val resolvedActivityList = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M)
            pm.queryIntentActivities(activityIntent, PackageManager.MATCH_ALL)
        else pm.queryIntentActivities(activityIntent, 0)
        val packagesSupportingCustomTabs = mutableListOf<String>()
        for (info in resolvedActivityList) {
            val serviceIntent = Intent()
            serviceIntent.action = CustomTabsService.ACTION_CUSTOM_TABS_CONNECTION
            serviceIntent.setPackage(info.activityInfo.packageName)
            if (pm.resolveService(serviceIntent, 0) != null) {
                packagesSupportingCustomTabs.add(info.activityInfo.packageName)
            }
        }

        var packageNameToUse: String? = null
        if (packagesSupportingCustomTabs.isEmpty()) {
            packageNameToUse = defaultViewHandlerPackageName
        } else if (!TextUtils.isEmpty(defaultViewHandlerPackageName) &&
            !hasSpecializedHandlerIntents(context, activityIntent) &&
            packagesSupportingCustomTabs.contains(defaultViewHandlerPackageName)
        ) {
            packageNameToUse = defaultViewHandlerPackageName
        } else if (packagesSupportingCustomTabs.contains(STABLE_PACKAGE)) {
            packageNameToUse = STABLE_PACKAGE
        } else if (packagesSupportingCustomTabs.contains(BETA_PACKAGE)) {
            packageNameToUse = BETA_PACKAGE
        } else if (packagesSupportingCustomTabs.contains(DEV_PACKAGE)) {
            packageNameToUse = DEV_PACKAGE
        } else if (packagesSupportingCustomTabs.contains(LOCAL_PACKAGE)) {
            packageNameToUse = LOCAL_PACKAGE
        } else if (packagesSupportingCustomTabs.size >= 1) {
            packageNameToUse = packagesSupportingCustomTabs[0]
        }
        return packageNameToUse
    }

    private fun hasSpecializedHandlerIntents(context: Context, intent: Intent): Boolean {
        try {
            val pm = context.packageManager
            val handlers = pm.queryIntentActivities(
                intent,
                PackageManager.GET_RESOLVED_FILTER
            )
            if (handlers == null || handlers.size == 0) {
                return false
            }
            for (resolveInfo in handlers) {
                val filter = resolveInfo.filter ?: continue
                if (filter.countDataAuthorities() == 0 || filter.countDataPaths() == 0)
                    continue
                if (resolveInfo.activityInfo == null) continue
                return true
            }
        } catch (e: RuntimeException) {
        }
        return false
    }
}
