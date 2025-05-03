# Keep JavascriptInterface for WebView bridge
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

# Razorpay specific rules
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

# Disable optimization for methods that handle payments
-optimizations !method/inlining/*

# Keep payment callback methods
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Keep any proguard annotation classes that might be missing
-dontwarn proguard.annotation.**

# WebView
-keep class android.webkit.** { *; }

# Prevent R8 from failing on missing classes
-ignorewarnings

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}