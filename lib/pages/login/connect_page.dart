import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/widgets/fullscreen_box.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {

  ApiManager apiManager = getIt<ApiManager>();
  String value = "";


  _ConnectPageState() {
    value = apiManager.baseUrl;
  }

  void onChanged(String newValue) {
    setState(() {
      value = newValue;
    });
  }

  Future<void> connect() async {
    try {
      final apiManager = getIt<ApiManager>();
      apiManager.setBaseUrl(value);
      await apiManager.checkConnection();
      GoRouter.of(context).push('/login');
    }
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection failed: $e"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;

    return FullScreenBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            lm.connect_title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            lm.connect_description
          ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: lm.connect_placeholder_instance,
                labelText: lm.connect_label_instance
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                connect();
              },
              onChanged: onChanged,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              connect();
            },
            child: Text(lm.connect_button_connect),
          ),
        ],
      ),
    );
  }
}