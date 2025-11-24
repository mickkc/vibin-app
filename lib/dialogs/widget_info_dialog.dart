import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/dtos/widgets/shared_widget.dart';
import 'package:vibin_app/dtos/widgets/widget_type.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/dialogs.dart';

import '../l10n/app_localizations.dart';

class WidgetInfoDialog extends StatelessWidget {
  final SharedWidget widget;

  const WidgetInfoDialog({super.key, required this.widget});

  String _getUrl() {
    final apiManager = getIt<ApiManager>();
    return "${apiManager.baseUrl}/api/widgets/${widget.id}";
  }

  String _getEmbedCode() {
    return "<iframe\n"
        "\tsrc=\"${_getUrl()}\"\n"
        "\twidth=\"360\"\n"
        "\theight=\"720\"\n"
        "\tstyle=\"border:none;overflow:hidden\"\n"
        "\tframeborder=\"0\"\n"
        "></iframe>";
  }

  static Future<void> show(BuildContext context, SharedWidget widget) async {
    return showDialog(
      context: context,
      builder: (context) => WidgetInfoDialog(widget: widget),
    );
  }

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(lm.settings_widgets_info_title),
      constraints: BoxConstraints(
        maxWidth: 500,
        maxHeight: 600,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ListTile(
              title: Text(lm.settings_widgets_id_title),
              subtitle: Text(widget.id),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.id));
                Dialogs.showInfoDialog(context, lm.settings_widgets_id_copied);
              },
            ),
            ListTile(
              title: Text(lm.settings_widgets_types_title),
              subtitle: Text(
                  widget.types.map((t) => WidgetType.translateFromString(t, lm)).join(", ")
              ),
            ),
            ListTile(
              title: Text(lm.settings_widgets_embed_code_title),
              subtitle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  _getEmbedCode(),
                  style: TextStyle(fontFamily: "monospace"),
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _getEmbedCode()));
                  Dialogs.showInfoDialog(context, lm.settings_widgets_embed_code_copied);
                },
                icon: const Icon(Icons.copy),
                tooltip: lm.settings_widgets_embed_code_copy,
              ),
            ),
            ListTile(
              title: Text(lm.settings_widgets_open_in_browser),
              leading: const Icon(Icons.open_in_browser),
              onTap: () {
                launchUrl(Uri.parse(_getUrl()));
              }
            )
          ],
        )
      ),
    );
  }
}