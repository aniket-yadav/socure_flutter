import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/socure_docv_options.dart';
import 'models/socure_docv_result.dart';
import 'socure_flutter_method_channel.dart';

abstract class SocureFlutterPlatform extends PlatformInterface {
  /// Constructs a SocureFlutterPlatform.
  SocureFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocureFlutterPlatform _instance = MethodChannelSocureFlutter();

  /// The default instance of [SocureFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSocureFlutter].
  static SocureFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SocureFlutterPlatform] when
  /// they register themselves.
  static set instance(SocureFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Launches the Socure DocV SDK for document verification.
  ///
  /// Takes [SocureDocVOptions] containing the SDK key and transaction token.
  /// Returns a [SocureDocVResult] which is either:
  /// - [SocureDocVSuccess] with a device session token on success
  /// - [SocureDocVFailure] with error details on failure
  ///
  /// Example:
  /// ```dart
  /// final options = SocureDocVOptions(
  ///   sdkKey: 'your-sdk-key',
  ///   transactionToken: 'transaction-token-from-backend',
  /// );
  /// final result = await SocureFlutter().launchDocV(options);
  /// ```
  Future<SocureDocVResult> launchDocV(SocureDocVOptions options) {
    throw UnimplementedError('launchDocV() has not been implemented.');
  }

  /// Gets the platform version (for testing purposes).
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
