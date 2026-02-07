package com.prosahi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.system.Os
import android.system.OsConstants

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.prosahi.app/page_size"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getPageSize") {
                    try {
                        val pageSize = Os.sysconf(OsConstants._SC_PAGESIZE)
                        result.success(pageSize)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get page size: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
