import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:vibin_app/dependency_injection.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/router.dart';

import 'auth/AuthState.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDependencyInjection();

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

class MyApp extends StatelessWidget {

  final AuthState authState;

  const MyApp({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {

    final router = configureRouter(authState);

    return MaterialApp.router(
      title: 'Vibin\'',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        fontFamily: "Roboto Flex",
      ),
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
}

