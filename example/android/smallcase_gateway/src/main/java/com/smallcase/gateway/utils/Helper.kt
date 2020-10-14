package com.smallcase.gateway.utils

import android.app.Activity
import android.content.Context
import android.graphics.Typeface
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import com.smallcase.gateway.R
import com.smallcase.gateway.data.SdkConstants
import java.util.regex.Matcher
import java.util.regex.Pattern
import kotlin.math.roundToInt


fun String.getError(): SdkConstants.ErrorMap {
    return when {
        this == "UserMismatch" || this == SdkConstants.CompletionStatus.USER_MISMATCH -> SdkConstants.ErrorMap.USER_MISMATCH
        this == "TrxidExpired" || this == SdkConstants.CompletionStatus.TRX_ID_EXPIRED -> SdkConstants.ErrorMap.TRX_ID_EXPIRED
        this == "APIError" || this == SdkConstants.CompletionStatus.API_ERROR -> SdkConstants.ErrorMap.API_ERROR
        this == "UserCancelled" || this == SdkConstants.CompletionStatus.USER_CANCELLED -> SdkConstants.ErrorMap.USER_CANCELLED
        this == "HoldingImportError" || this == SdkConstants.CompletionStatus.HOLDING_IMPORT_ERROR -> SdkConstants.ErrorMap.HOLDING_IMPORT_ERROR
        this == "CONSENT_DENIED" || this == SdkConstants.CompletionStatus.CONSENT_DENIED -> SdkConstants.ErrorMap.CONSENT_DENIED
        this == "INSUFFICIENT_HOLDINGS" || this == SdkConstants.CompletionStatus.INSUFFICIENT_HOLDINGS -> SdkConstants.ErrorMap.INSUFFICIENT_HOLDINGS
        this == "MARKET_CLOSED" || this == SdkConstants.CompletionStatus.MARKET_CLOSED_ERROR -> SdkConstants.ErrorMap.MARKET_CLOSED_ERROR
        this == "TIMED_OUT" || this == SdkConstants.ErrorMap.TIMED_OUT.error -> SdkConstants.ErrorMap.TIMED_OUT
        else -> SdkConstants.ErrorMap.API_ERROR
    }
}

fun Activity.getScreenWidth():Int
{
    val displayMetrics = DisplayMetrics()
    windowManager.defaultDisplay.getMetrics(displayMetrics)
    return displayMetrics.widthPixels
}

/**
 * This method converts dp unit to equivalent pixels, depending on device density.
 *
 * @param dp A value in dp (density independent pixels) unit. Which we need to convert into pixels
 * @param context Context to get resources and device specific display metrics
 * @return A float value to represent px equivalent to dp depending on device density
 */
fun Context.convertDpToPixel(dp: Int): Int {
    val density: Float = resources.displayMetrics.density
    return (dp.toFloat() * density).roundToInt()
}

/**
 * This method converts device specific pixels to density independent pixels.
 *
 * @param px A value in px (pixels) unit. Which we need to convert into db
 * @param context Context to get resources and device specific display metrics
 * @return A float value to represent dp equivalent to px value
 */
fun Context.convertPixelsToDp(px: Float): Float {
    return px / (resources
        .displayMetrics.densityDpi.toFloat() / DisplayMetrics.DENSITY_DEFAULT)
}


fun getHeight(
    context: Context?,
    text: CharSequence?,
    textSize: Int,
    deviceWidth: Int,
    typeface: Typeface?,
    padding: Int
): Int {
    val textView = TextView(context)
    textView.setPadding(padding, 0, padding, padding)
    textView.setTypeface(typeface)
    textView.setLineSpacing(1.0f,1.33f)
    textView.setText(text, TextView.BufferType.SPANNABLE)
    textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, textSize.toFloat())
    val widthMeasureSpec: Int =
        View.MeasureSpec.makeMeasureSpec(deviceWidth, View.MeasureSpec.AT_MOST)
    val heightMeasureSpec: Int = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
    textView.measure(widthMeasureSpec, heightMeasureSpec)
    return textView.measuredHeight
}

fun Context.makeSpannable(text: String, regex: String,startString:String, endString:String): SpannableStringBuilder? {
    val sb = StringBuffer()
    val spannable = SpannableStringBuilder()
    val pattern: Pattern = Pattern.compile(regex)
    val matcher: Matcher = pattern.matcher(text)
    while (matcher.find()) {
        sb.setLength(0) // clear
        val group: String = matcher.group()
        // caution, this code assumes your regex has single char delimiters
        val spanText = group.substring(startString.length, group.length - endString.length)
        matcher.appendReplacement(sb, spanText)
        spannable.append(sb.toString())
        val start = spannable.length - spanText.length
        spannable.setSpan(
            ForegroundColorSpan(ContextCompat.getColor(this, R.color.consent_bold)),
            start,
            spannable.length,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        val typeface = ResourcesCompat.getFont(this.applicationContext, R.font.graphikapp_medium)!!
        spannable.setSpan(CustomTypefaceSpan("",typeface),start,spannable.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
    }
    sb.setLength(0)
    matcher.appendTail(sb)
    spannable.append(sb.toString())
    return spannable
}