import '../types.dart';

class WalletApp {
  final String appName;
  final String name;
  final String bridgeUrl;
  final String image;
  final String? universalUrl;
  final String aboutUrl;
  final List<String>? platforms;

  const WalletApp({
    required this.appName,
    required this.name,
    required this.bridgeUrl,
    required this.image,
    required this.aboutUrl,
    this.universalUrl,
    this.platforms,
  });

  factory WalletApp.fromMap(Json json) {
    String bridgeUrl = json.containsKey('bridge_url')
        ? json['bridge_url'].toString()
        : (json.containsKey('bridge')
            ? (json['bridge'] as List)
                .firstWhere((bridge) => bridge['type'] == 'sse',
                    orElse: () => {'url': ''})['url']
                .toString()
            : '');

    return WalletApp(
      appName: json['app_name'],
      name: json['name'].toString(),
      image: json['image'].toString(),
      bridgeUrl: bridgeUrl,
      aboutUrl: json['about_url'].toString(),
      universalUrl: json.containsKey('universal_url')
          ? json['universal_url'].toString()
          : null,
      platforms: json.containsKey('platforms')
          ? (json['platforms'] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }
}
