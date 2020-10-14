import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('scgateway_flutter_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ScgatewayFlutterPlugin.platformVersion, '42');
  });
}
