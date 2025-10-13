import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {

  final apiManager = getIt<ApiManager>();
  late TextEditingController controller;

  late final lm = AppLocalizations.of(context)!;
  late final router = GoRouter.of(context);

  Future<void> connect() async {
    try {
      apiManager.setBaseUrl(controller.text);
      await apiManager.checkConnection();
      if (mounted) router.replace("/login");
    }
    catch (e) {
      if (mounted) showSnackBar(context, lm.connect_error);
    }
  }

  @override
  void initState() {
    controller = TextEditingController(text: apiManager.baseUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              onSubmitted: (_) => connect(),
              controller: controller,
            ),
          ),
          ElevatedButton(
            onPressed: connect,
            child: Text(lm.connect_button_connect),
          ),
        ],
      ),
    );
  }
}