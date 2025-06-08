package com.example.foodam


import android.content.IntentFilter
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.foodam.sms/method"
    private val EVENT_CHANNEL = "com.foodam.sms/events"

    private var eventSink: EventChannel.EventSink? = null
    private val smsReceiver = SmsReceiver()
    private var isListening = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startSmsListener" -> {
                        startSmsListener()
                        result.success("SMS listener started")
                    }
                    "stopSmsListener" -> {
                        stopSmsListener()
                        result.success("SMS listener stopped")
                    }
                    else -> result.notImplemented()
                }
            }

        // Setup Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    private fun startSmsListener() {
        if (isListening) return

        try {
            // Set up SMS listener callback
            SmsReceiver.smsListener = { sender, body ->
                val smsData = mapOf(
                    "sender" to sender,
                    "body" to body,
                    "timestamp" to System.currentTimeMillis()
                )

                // Send SMS data to Flutter
                runOnUiThread {
                    eventSink?.success(smsData)
                }
            }

            // Register SMS receiver
            val intentFilter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            intentFilter.priority = 1000 // High priority to receive SMS first
            registerReceiver(smsReceiver, intentFilter)

            isListening = true
            android.util.Log.d("MainActivity", "SMS listener started")

        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error starting SMS listener: ${e.message}")
        }
    }

    private fun stopSmsListener() {
        if (!isListening) return

        try {
            unregisterReceiver(smsReceiver)
            SmsReceiver.smsListener = null
            isListening = false
            android.util.Log.d("MainActivity", "SMS listener stopped")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error stopping SMS listener: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopSmsListener()
    }
}