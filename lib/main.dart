import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
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
import 'package:flutter_web_plugins/url_strategy.dart';

import 'api/api_manager.dart';
import 'auth/auth_state.dart';

final getIt = GetIt.instance;

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => authState,
      child: MyApp(authState: authState),
    ),
  );
}

final themeNotifier = ValueNotifier(ThemeSettings());

class MyApp extends StatelessWidget {

  final AuthState authState;

  const MyApp({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {

    final SettingsManager settingsManager = getIt<SettingsManager>();

    themeNotifier.value.accentColor = settingsManager.get(Settings.accentColor);
    themeNotifier.value.colorSchemeKey = settingsManager.get(Settings.colorScheme);
    themeNotifier.value.themeMode = settingsManager.get(Settings.themeMode);

    themeNotifier.value = themeNotifier.value.validate(context);

    if (isEmbeddedMode()) {
      final apiManager = getIt<ApiManager>();
      apiManager.setBaseUrl("");
    }

    final router = configureRouter(authState);

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
          routerConfig: router,
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

