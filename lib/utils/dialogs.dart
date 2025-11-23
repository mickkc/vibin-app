import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../widgets/network_image.dart';

class Dialogs {

  static Future<bool> showConfirmDialog(BuildContext context, String title, String content, {String? confirmText, String? cancelText}) async {
    bool confirmed = false;
    final lm = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(cancelText ?? lm.dialog_cancel)
          ),
          ElevatedButton(
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
            },
            child: Text(confirmText ?? lm.dialog_confirm)
          )
        ],
      )
    );
    return confirmed;
  }

  static Future<void> showMessageDialog(BuildContext context, String title, String content, {String? buttonText, IconData? icon}) async {
    final lm = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon != null ? Icon(icon, size: 48) : null,
        title: Text(title),
        content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(content)
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(buttonText ?? lm.dialog_confirm)
          )
        ],
      )
    );
  }

  static Future<void> showInfoDialog(BuildContext context, String content) async {
    final lm = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.info, size: 48, color: Theme.of(context).colorScheme.primary),
        title: Text(lm.dialog_info),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(lm.dialog_confirm)
          )
        ],
      )
    );
  }

  static Future<String?> showInputDialog(BuildContext context, String title, String label, {String? initialValue, String? hintText, String? confirmText, String? cancelText}) async {
    final lm = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(text: initialValue ?? "");

    String? result;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
          ),
          autofocus: true,
          onSubmitted: (value) {
            result = value;
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(cancelText ?? lm.dialog_cancel)
          ),
          ElevatedButton(
            onPressed: () {
              result = controller.text;
              Navigator.pop(context);
            },
            child: Text(confirmText ?? lm.dialog_confirm)
          )
        ],
      )
    );
    return result;
  }

  static Future<void> showAboutAppDialog(BuildContext context) async {
    final lm = AppLocalizations.of(context)!;

    final packageInfo = await PackageInfo.fromPlatform();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: lm.app_name,
        applicationVersion: packageInfo.version,
        applicationIcon: const Icon(Icons.library_music, size: 64),
        children: [

          SizedBox(
            width: 300,
            height: 200,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [

                ListTile(
                  leading: NetworkImageWidget(
                    url: "https://avatars.githubusercontent.com/u/67842588",
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Text("MickKC"),
                  subtitle: Text(lm.settings_app_about_credits_developer),
                  onTap: () => launchUrl(Uri.parse("https://github.com/mickkc")),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text("GitHub"),
                  onTap: () => launchUrl(Uri.parse("https://github.com/mickkc/vibin")),
                ),

                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: Text(lm.settings_app_about_report_issue),
                  onTap: () => launchUrl(Uri.parse("https://github.com/mickkc/vibin/issues")),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}