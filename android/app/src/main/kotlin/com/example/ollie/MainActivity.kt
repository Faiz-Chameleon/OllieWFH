package com.example.ollie

import java.util.TimeZone
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.shahwaiz.meditrace/time_zone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "getIanaTimeZone") {
                val timeZone = TimeZone.getDefault().id
                Log.d("DeviceTimeZone", "Android timezone: $timeZone")
                result.success(timeZone)
            } else {
                result.notImplemented()
            }
        }
    }
}
