// android/app/src/main/kotlin/com/foodam/app/SmsReceiver.kt
package com.example.foodam
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        var smsListener: ((String, String) -> Unit)? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

                for (message in messages) {
                    val sender = message.originatingAddress ?: ""
                    val body = message.messageBody ?: ""

                    Log.d(TAG, "SMS received from: $sender")
                    Log.d(TAG, "SMS body: $body")

                    // Notify Flutter about the SMS
                    smsListener?.invoke(sender, body)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing SMS: ${e.message}")
            }
        }
    }
}