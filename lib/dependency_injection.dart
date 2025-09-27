import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/api/client_data.dart';
import 'package:vibin_app/audio/audio_manager.dart';

import 'auth/AuthState.dart';
import 'main.dart';

Future<void> setupDependencyInjection() async {
  final apiManager = ApiManager();
  getIt.registerSingleton<ApiManager>(apiManager);

  final authState = AuthState();
  getIt.registerSingleton<AuthState>(authState);

  final clientData = await ClientData.loadOrRandom();
  getIt.registerSingleton<ClientData>(clientData);

  final audioManager = AudioManager();
  getIt.registerSingleton<AudioManager>(audioManager);
}