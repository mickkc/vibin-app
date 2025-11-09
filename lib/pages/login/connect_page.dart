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

  final _apiManager = getIt<ApiManager>();
  late final TextEditingController _controller;

  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);
  late final _router = GoRouter.of(context);

  Future<void> _connect() async {
    try {
      _apiManager.setBaseUrl(_controller.text);
      await _apiManager.checkConnection();
      if (mounted) _router.replace("/login");
    }
    catch (e) {
      if (mounted) showSnackBar(context, _lm.connect_error);
    }
  }

  @override
  void initState() {
    _controller = TextEditingController(text: _apiManager.baseUrl);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Text(
          _lm.connect_title,
          style: _theme.textTheme.headlineMedium,
        ),
        Text(
          _lm.connect_description
        ),
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: _lm.connect_placeholder_instance,
              labelText: _lm.connect_label_instance
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _connect(),
            controller: _controller,
          ),
        ),
        ElevatedButton(
          onPressed: _connect,
          child: Text(_lm.connect_button_connect),
        ),
      ],
    );
  }
}