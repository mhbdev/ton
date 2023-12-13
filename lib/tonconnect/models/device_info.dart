import '../types.dart';

enum DevicePlatform {
  iphone("iphone"),
  ipad("ipad"),
  android("android"),
  windows("windows"),
  mac("mac"),
  linux("linux"),
  browser("browser");

  const DevicePlatform(this.value);
  final String value;

  static getDevicePlatformByValue(String platform) {
    return DevicePlatform.values.firstWhere((e) => e.value == platform);
  }
}

class DeviceInfo {
  final DevicePlatform
  platform; // 'iphone' | 'ipad' | 'android' | 'windows' | 'mac' | 'linux' | 'browser'
  final String appName; // e.g. "Tonkeeper"
  final String appVersion; // e.g. "2.3.367"
  final int maxProtocolVersion;
  final List<dynamic> features;

  DeviceInfo(this.platform, this.appName, this.appVersion, this.maxProtocolVersion, this.features);

  static DeviceInfo fromMap(Json device) {
    return DeviceInfo(
      DevicePlatform.getDevicePlatformByValue(device['platform'].toString()),
      device['appName'].toString(),
      device['appVersion'].toString(),
      int.tryParse(device['maxProtocolVersion'].toString()) ?? 0,
      device['features'] ?? [],
    );
  }
}