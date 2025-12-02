import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:vibin_app/dbus/mpris_player.dart';
import 'package:vibin_app/dependency_injection.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/router.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';
import 'package:vibin_app/themes/color_scheme_list.dart';
import 'package:vibin_app/widgets/settings/theme_settings.dart';

import 'api/api_manager.dart';
import 'auth/auth_state.dart';

final getIt = GetIt.instance;

final supportedServerVersions = [
  "0.0.1-beta.3"
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencyInjection();

  JustAudioMediaKit.ensureInitialized();

  final settingsManager = getIt<SettingsManager>();

  if (!kIsWeb && Platform.isLinux && settingsManager.get(Settings.linuxEnableDbusMpris)) {
    final session = DBusClient.session();
    final mpris = MprisPlayer();

    session.registerObject(mpris);
    await session.requestName("org.mpris.MediaPlayer2.vibin");
  }

  tz.initializeTimeZones();

  final authState = getIt<AuthState>();

  final autoLoginResult = await authState.tryAutoLogin();
  authState.autoLoginResult = autoLoginResult;

  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    ChangeNotifierProvider(
      create: (context) => authState,
      child: MyApp(authState: authState),
    ),
  );
}

final themeNotifier = ValueNotifier(ThemeSettings());

class MyApp extends StatefulWidget {

  final AuthState authState;

  const MyApp({super.key, required this.authState});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late final GoRouter _router;
  bool _themeValidated = false;

  @override
  void initState() {
    super.initState();

    final SettingsManager settingsManager = getIt<SettingsManager>();

    themeNotifier.value.accentColor = settingsManager.get(Settings.accentColor);
    themeNotifier.value.colorSchemeKey = settingsManager.get(Settings.colorScheme);
    themeNotifier.value.themeMode = settingsManager.get(Settings.themeMode);

    if (isEmbeddedMode()) {
      final apiManager = getIt<ApiManager>();
      apiManager.setBaseUrl("");
    }

    _router = configureRouter(widget.authState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Validate theme with context (only once when context becomes available)
    if (!_themeValidated) {
      themeNotifier.value = themeNotifier.value.validate(context);
      _themeValidated = true;
    }
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, themeSettings, _) {
        return MaterialApp.router(
          title: 'Vibin\'',
          theme: ColorSchemeList.get(themeSettings.colorSchemeKey)
            .generateThemeData(accentColor: themeSettings.accentColor, brightness: Brightness.light),
          darkTheme: ColorSchemeList.get(themeSettings.colorSchemeKey)
            .generateThemeData(accentColor: themeSettings.accentColor, brightness: Brightness.dark),
          themeMode: themeSettings.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: AppLocalizations.supportedLocales
        );
      },
    );
  }
}

