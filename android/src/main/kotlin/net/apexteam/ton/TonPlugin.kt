package net.apexteam.ton

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.ton.mnemonic.Mnemonic
import kotlin.coroutines.CoroutineContext

/** TonPlugin */
class TonPlugin: FlutterPlugin, MethodCallHandler, CoroutineScope {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ton")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "generateRandomMnemonic" -> {
            val password = call.argument<String?>("password")
            val wordCount = call.argument<Int>("wordCount")!!
          launch {
              val mnemonic = if(password == null) {
                  Mnemonic.generate(wordCount= wordCount)
              } else {
                  Mnemonic.generate(password= password, wordCount= wordCount)
              }
            result.success(mnemonic)
          }
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override val coroutineContext: CoroutineContext
    get() = Dispatchers.Main
}
