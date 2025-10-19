import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
