import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/success.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/future_content.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/datetime_utils.dart';

class UserInfoView extends StatefulWidget {
  final User user;

  const UserInfoView({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {

  late final _lm = AppLocalizations.of(context)!;
  final _authState = getIt<AuthState>();
  final _apiManager = getIt<ApiManager>();
  late Future<Success> _canVerifyEmailFuture = _apiManager.service.canVerifyEmail();

  void _resendVerificationEmail() async {
    try {
      final response = await _apiManager.service.sendVerificationEmail();
      if (!mounted) return;
      if (response.success) {
        showSnackBar(context, _lm.user_info_email_resend_success(widget.user.email!), seconds: 10);
      }
      else {
        ErrorHandler.showErrorDialog(context, _lm.user_info_email_resend_error);
      }
    }
    catch (e, st) {
      if (mounted) {
        ErrorHandler.showErrorDialog(context, _lm.user_info_email_resend_error, error: e, stackTrace: st);
      }
    }
    finally {
      setState(() {
        _canVerifyEmailFuture = _apiManager.service.canVerifyEmail();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ListTile(
          title: Text(_lm.user_info_username),
          subtitle: Text(widget.user.username),
          leading: const Icon(Icons.person),
        ),
        if (widget.user.displayName != null)
          ListTile(
            title: Text(_lm.user_info_display_name),
            subtitle: Text(widget.user.displayName!),
            leading: const Icon(Icons.badge),
          ),
        if (widget.user.description.isNotEmpty)
          ListTile(
            title: Text(_lm.user_info_bio),
            subtitle: Text(widget.user.description),
            leading: const Icon(Icons.description),
          ),
        if (widget.user.email != null)
          ListTile(
            title: Text(_lm.user_info_email),
            subtitle: Text(widget.user.emailVerified ? widget.user.email! : _lm.user_info_email_unverified(widget.user.email!)),
            leading: const Icon(Icons.email),
            trailing: widget.user.id == _authState.user?.id && !widget.user.emailVerified
              ? FutureContent(
                future: _canVerifyEmailFuture,
                mockData: () => Success(success: false),
                builder: (context, canVerify) {
                  return canVerify.success ? IconButton.filled(
                    onPressed: _resendVerificationEmail,
                    tooltip: _lm.user_info_email_resend,
                    icon: const Icon(Icons.refresh),
                  ) : const SizedBox.shrink();
                }
              ) : null,
          ),
        ListTile(
          title: Text(_lm.user_info_joined),
          subtitle: Text(DateTimeUtils.convertUtcUnixToLocalTimeString(widget.user.createdAt, _lm.datetime_format_full)),
          leading: const Icon(Icons.calendar_today),
        ),
        ListTile(
          title: Text(_lm.user_info_active),
          subtitle: Text(widget.user.isActive ? _lm.dialog_yes : _lm.dialog_no),
          leading: const Icon(Icons.check_circle),
        ),
        ListTile(
          title: Text(_lm.user_info_admin),
          subtitle: Text(widget.user.isAdmin ? _lm.dialog_yes : _lm.dialog_no),
          leading: const Icon(Icons.admin_panel_settings),
        ),
      ],
    );
  }
}