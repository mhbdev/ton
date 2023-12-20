import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_state.dart';

const List<Locale> supportedLocales = [Locale('en', 'US')];

class TonConnectUiProvider extends StatelessWidget {
  final Widget child;
  final bool? lazy;
  final String manifestUrl;
  final Locale? locale;
  final ThemeMode themeMode;

  TonConnectUiProvider({
    super.key,
    required this.child,
    required this.manifestUrl,
    this.lazy,
    this.locale,
    this.themeMode = ThemeMode.light,
  }) : assert(locale == null || supportedLocales.contains(locale));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TonConnectState(
        context: context,
        manifestUrl: manifestUrl,
      ),
      lazy: lazy,
      child: child,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: locale ?? Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'),
          delegates: [
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                basePath: 'assets/i18n',
                useCountryCode: true,
                forcedLocale: locale ?? const Locale('en', 'US'),
              ),
            ),
          ],
          child: FlutterI18n.rootAppBuilder()(context, TonConnectWrapper(child: child!)),
        );
      },
    );
  }
}

class TonConnectWrapper extends StatefulWidget {
  final Widget child;

  const TonConnectWrapper({super.key, required this.child});

  @override
  State<TonConnectWrapper> createState() => _TonConnectWrapperState();
}

class _TonConnectWrapperState extends State<TonConnectWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Provider.of<TonConnectState>(context, listen: false).connected) {
        Provider.of<TonConnectState>(context, listen: false).restoreConnection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
