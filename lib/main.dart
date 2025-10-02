import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:provider/provider.dart';
import 'package:vibin_app/audio/audio_manager.dart';
import 'package:vibin_app/dbus/mpris_player.dart';
import 'package:vibin_app/dependency_injection.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/router.dart';
import 'package:vibin_app/settings/setting_definitions.dart';
import 'package:vibin_app/settings/settings_manager.dart';

import 'auth/AuthState.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencyInjection();

  JustAudioMediaKit.ensureInitialized();

  await AudioManager.initBackgroundTask();

  if (Platform.isLinux) {
    final session = DBusClient.session();
    final mpris = MprisPlayer();

    session.registerObject(mpris);
    await session.requestName("org.mpris.MediaPlayer2.vibin");
  }

  final authState = getIt<AuthState>();

  final autoLoginResult = await authState.tryAutoLogin();
  authState.autoLoginResult = autoLoginResult;

  runApp(
    ChangeNotifierProvider(
      create: (context) => authState,
      child: MyApp(authState: authState),
    ),
  );
}

final themeModeNotifier = ValueNotifier(ThemeMode.system);

class MyApp extends StatelessWidget {

  final AuthState authState;

  const MyApp({super.key, required this.authState});


  @override
  Widget build(BuildContext context) {

    final SettingsManager settingsManager = getIt<SettingsManager>();
    themeModeNotifier.value = settingsManager.get(Settings.themeMode);

    final router = configureRouter(authState);

    return ValueListenableBuilder(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            return MaterialApp.router(
              title: 'Vibin\'',
              theme: ThemeData(
                colorScheme: lightColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.green),
                fontFamily: "Roboto Flex",
                useMaterial3: true
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
                fontFamily: "Roboto Flex",
                useMaterial3: true
              ),
              themeMode: themeMode,
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
          }
        );
      },
    );
  }
}

