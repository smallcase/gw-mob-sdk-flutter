package com.smallcase.gateway.extensions

import android.annotation.SuppressLint
import android.app.Activity
import android.content.pm.ActivityInfo
import android.os.Build


@SuppressLint("SourceLockedOrientationActivity")
fun Activity.setOrientation() {
    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.O) this.requestedOrientation =
        ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED else this.requestedOrientation =
        ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
}
