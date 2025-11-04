package com.aniketlabs.socure_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.socure.docv.capturesdk.api.SocureSdk
import com.socure.docv.capturesdk.api.SocureDocVContext
import com.socure.docv.capturesdk.api.SocureDocVError
import com.socure.docv.capturesdk.common.utils.SocureDocVFailure
import com.socure.docv.capturesdk.common.utils.SocureDocVSuccess
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** SocureFlutterPlugin */
class SocureFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var pendingResult: Result? = null

    companion object {
        private const val REQUEST_CODE_DOCV = 1001
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "socure_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "launchDocV" -> {
                launchDocV(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun launchDocV(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                "NO_ACTIVITY",
                "Activity not available",
                null
            )
            return
        }

        // Check if there's already a pending result
        if (pendingResult != null) {
            result.error(
                "ALREADY_ACTIVE",
                "A DocV session is already active",
                null
            )
            return
        }

        try {
            // Extract parameters
            val sdkKey = call.argument<String>("sdkKey")
            val transactionToken = call.argument<String>("transactionToken")
            val useSocureGov = call.argument<Boolean>("useSocureGov") ?: false

            if (sdkKey.isNullOrEmpty()) {
                result.error("INVALID_KEY", "SDK key is required", null)
                return
            }

            if (transactionToken.isNullOrEmpty()) {
                result.error("INVALID_TOKEN", "Transaction token is required", null)
                return
            }

            // Store the result callback for later
            pendingResult = result

            // Build Socure DocV context (based on official Socure docs)
            val docVContext = SocureDocVContext(
                transactionToken,
                sdkKey,
                useSocureGov
            )

            // Get intent from Socure SDK
            val intent = SocureSdk.getIntent(currentActivity, docVContext)

            // Launch the DocV activity
            currentActivity.startActivityForResult(intent, REQUEST_CODE_DOCV)

        } catch (e: Exception) {
            pendingResult = null
            result.error(
                "INITIALIZATION_ERROR",
                "Failed to launch DocV: ${e.message}",
                null
            )
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_DOCV) {
            val result = pendingResult
            pendingResult = null

            if (result == null) {
                return true
            }

            if (data == null) {
                result.error(
                    "NO_DATA",
                    "No data returned from DocV SDK",
                    null
                )
                return true
            }

            // Process result using Socure SDK
            SocureSdk.getResult(data) { sdkResult ->
                when (sdkResult) {
                    is SocureDocVSuccess -> {
                        val resultMap = mapOf(
                            "success" to true,
                            "deviceSessionToken" to sdkResult.deviceSessionToken
                        )
                        result.success(resultMap)
                    }
                    is SocureDocVFailure -> {
                        val errorCode = mapErrorToCode(sdkResult.error)
                        val resultMap = mapOf(
                            "success" to false,
                            "errorCode" to errorCode,
                            "errorMessage" to sdkResult.error.toString(),
                            "deviceSessionToken" to sdkResult.deviceSessionToken
                        )
                        result.success(resultMap)
                    }
                }
            }
            return true
        }
        return false
    }

    private fun mapErrorToCode(error: SocureDocVError): String {
        return when (error) {
            SocureDocVError.INVALID_PUBLIC_KEY -> "INVALID_KEY"
            SocureDocVError.INVALID_DOCV_TRANSACTION_TOKEN -> "INVALID_TOKEN"
            SocureDocVError.NO_INTERNET_CONNECTION -> "NETWORK_ERROR"
            SocureDocVError.USER_CANCELED -> "USER_CANCELED"
            SocureDocVError.CAMERA_PERMISSION_DECLINED -> "CAMERA_PERMISSION_DENIED"
            SocureDocVError.SESSION_EXPIRED -> "SESSION_EXPIRED"
            SocureDocVError.SESSION_INITIATION_FAILURE -> "INITIALIZATION_ERROR"
            SocureDocVError.DOCUMENT_UPLOAD_FAILURE -> "CAPTURE_ERROR"
            SocureDocVError.CONSENT_DECLINED -> "CONSENT_DECLINED"
            SocureDocVError.UNKNOWN -> "UNKNOWN"
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
