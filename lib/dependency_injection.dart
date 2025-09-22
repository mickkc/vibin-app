import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/audio/audio_manager.dart';

import 'auth/AuthState.dart';
import 'main.dart';

void setupDependencyInjection() {
  final apiManager = ApiManager();
  getIt.registerSingleton<ApiManager>(apiManager);

  final authState = AuthState();
  getIt.registerSingleton<AuthState>(authState);

  final audioManager = AudioManager();
  getIt.registerSingleton<AudioManager>(audioManager);
}