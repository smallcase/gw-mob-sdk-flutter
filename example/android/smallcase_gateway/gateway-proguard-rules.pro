

# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html


# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

### RxJava, RxAndroid (https://gist.github.com/kosiara/487868792fbd3214f9c9)
-keep class rx.schedulers.Schedulers {
    public static <methods>;
}
-keep class rx.schedulers.ImmediateScheduler {
    public <methods>;
}
-keep class rx.schedulers.TestScheduler {
    public <methods>;
}
-keep class rx.schedulers.Schedulers {
    public static ** test();
}
-keepclassmembers class rx.internal.util.unsafe.*ArrayQueue*Field* {
    long producerIndex;
    long consumerIndex;
}
-keepclassmembers class rx.internal.util.unsafe.BaseLinkedQueueProducerNodeRef {
    long producerNode;
    long consumerNode;
}
-keep class io.reactivex.schedulers.Schedulers {
    public static <methods>;
}
-keep class io.reactivex.schedulers.ImmediateScheduler {
    public <methods>;
}
-keep class io.reactivex.schedulers.TestScheduler {
    public <methods>;
}
-keep class io.reactivex.schedulers.Schedulers {
    public static ** test();
}
-keepclassmembers class io.reactivex.internal.util.unsafe.*ArrayQueue*Field* {
    long producerIndex;
    long consumerIndex;
}
-keepclassmembers class io.reactivex.internal.util.unsafe.BaseLinkedQueueProducerNodeRef {
    long producerNode;
    long consumerNode;
}

-keep class io.reactivex.android.schedulers.Schedulers {
    public static <methods>;
}
-keep class io.reactivex.android.schedulers.ImmediateScheduler {
    public <methods>;
}
-keep class io.reactivex.android.schedulers.TestScheduler {
    public <methods>;
}
-keep class io.reactivex.android.schedulers.Schedulers {
    public static ** test();
}
-keepclassmembers class io.reactivex.android.internal.util.unsafe.*ArrayQueue*Field* {
    long producerIndex;
    long consumerIndex;
}
-keepclassmembers class io.reactivex.android.internal.util.unsafe.BaseLinkedQueueProducerNodeRef {
    long producerNode;
    long consumerNode;
}
-dontwarn retrofit2.adapter.rxjava.CompletableHelper$** # https://github.com/square/retrofit/issues/2034
#To use Single instead of Observable in Retrofit interface
-keep class rx.Single
-keep class io.reactivex.Single
-keep class io.reactivex.SingleObserver
-dontwarn sun.misc.Unsafe

# Gson specific classes
-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.smallcase.gateway.data.models.** { *; }
-keep class com.smallcase.gateway.data.requests.** { *; }
-keep class com.smallcase.gateway.data.listeners.** { *;}


-keep class com.smallcase.gateway.screens.TransactionProcessActivity
-keep public class com.smallcase.gateway.screens.TransactionProcessActivity
#-keep class com.smallcase.gateway.base.** { *; }
-keep public class * extends androidx.appcompat.app.Activity







-keep class androidx.browser.** { *;}


# Prevent proguard from stripping interface information from TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep class * implements com.google.gson.** { *;}
-keep class * implements com.google.annotations.** { *;}

-keepattributes *Annotation*


# Gson specific classes
-keep class com.google.gson.stream.** { *; }



### Retrofit 2
# Platform calls Class.forName on types which do not exist on Android to determine platform.
-dontnote retrofit2.Platform
# Platform used when running on RoboVM on iOS. Will not be used at runtime.
-dontnote retrofit2.Platform$IOS$MainThreadExecutor
# Platform used when running on Java 8 VMs. Will not be used at runtime.
-dontwarn retrofit2.Platform$Java8
# Retain generic type information for use by reflection by converters and adapters.
-keepattributes Signature
# Retain declared state exceptions for use by a Proxy instance.
-keepattributes Exceptions


#Retrofit does reflection on generic parameters. InnerClasses is required to use Signature and
# EnclosingMethod is required to use InnerClasses.
-keepattributes Signature, InnerClasses, EnclosingMethod
# Retain service method parameters when optimizing.
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

### OkHttp3
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
# A resource is loaded with a relative path so the package of this class must be preserved.
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-dontwarn okhttp3.internal.platform.ConscryptPlatform



#Proguard rules for general
-keepclassmembers class * {    @android.webkit.JavascriptInterface <methods>;}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-optimizations !method/inlining/*


#Proguard rules for resources
-keepnames class com.smallcase.gateway.R$raw { *; }

#ignore from obsurfication
-keep class com.smallcase.gateway.portal.** { *; }

-keep class com.smallcase.gateway.data.ApiFactory { *; }

-keep class com.smallcase.gateway.data.SdkConstants { *; }

-keep class com.smallcase.gateway.data.SdkConstants.** { *; }

-keep class com.smallcase.gateway.data.** { *; }
