import 'package:flutter_test/flutter_test.dart';
import 'package:socure_flutter/socure_flutter.dart';
import 'package:socure_flutter/socure_flutter_platform_interface.dart';
import 'package:socure_flutter/socure_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSocureFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SocureFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SocureFlutterPlatform initialPlatform = SocureFlutterPlatform.instance;

  test('$MethodChannelSocureFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSocureFlutter>());
  });

  test('getPlatformVersion', () async {
    SocureFlutter socureFlutterPlugin = SocureFlutter();
    MockSocureFlutterPlatform fakePlatform = MockSocureFlutterPlatform();
    SocureFlutterPlatform.instance = fakePlatform;

    expect(await socureFlutterPlugin.getPlatformVersion(), '42');
  });
}
