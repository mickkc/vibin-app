import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/dtos/user/user_edit_data.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../api/api_manager.dart';
import '../../dialogs/delete_user_dialog.dart';
import '../../extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class UserEditPage extends StatefulWidget {
  final int? userId;
  final void Function(User) onSave;

  const UserEditPage({
    super.key,
    required this.userId,
    required this.onSave,
  });

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isAdmin = false;
  bool _isActive = true;
  String? _profileImageUrl;
  String? _initialUsername;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  final _emailRegexp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();
  late final _lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _apiManager.service.getUserById(widget.userId!).then((user) {
        setState(() {
          _usernameController.text = user.username;
          _displayNameController.text = user.displayName ?? "";
          _descriptionController.text = user.description;
          _emailController.text = user.email ?? "";
          _isAdmin = user.isAdmin;
          _isActive = user.isActive;
          _initialUsername = user.username;
        });
      }).catchError((emailController) {
        if (!mounted) return;
        showErrorDialog(context, _lm.edit_user_load_error);
      });
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {

      if (_initialUsername != null && _initialUsername != _usernameController.text) {
        final doesUserNameExist = await _apiManager.service.checkUsernameExists(
          _usernameController.text
        );

        if (doesUserNameExist.success) {
          if (!mounted) return;
          showErrorDialog(context, _lm.edit_user_username_validation_already_exists);
          return;
        }
      }

      final editData = UserEditData(
        username: _usernameController.text,
        displayName: _displayNameController.text.isEmpty ? null : _displayNameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        isAdmin: _isAdmin,
        isActive: _isActive,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        oldPassword: _currentPasswordController.text.isEmpty ? null : _currentPasswordController.text,
        profilePictureUrl: _profileImageUrl,
      );

      final savedUser = widget.userId == null
        ? await _apiManager.service.createUser(editData)
        : await _apiManager.service.updateUser(widget.userId!, editData);

      if (_profileImageUrl != null) {
        imageCache.clear();
        imageCache.clearLiveImages();
      }

      widget.onSave(savedUser);
    }
    catch (e) {
      log("Failed to save user: $e", error: e, level: Level.error.value);
      if (!mounted) return;
      showErrorDialog(context, _lm.edit_user_save_error);
    }
  }

  Future<void> delete() async {

    DeleteUserDialog.show(
      context,
      widget.userId!,
      (confirmed, deleteData) async {

        if (!confirmed) {
          return;
        }

        try {
          await _apiManager.service.deleteUser(widget.userId!, deleteData);
          if (!mounted) return;
          GoRouter.of(context).replace("/users");
        }
        catch (e) {
          log("Failed to delete user: $e", error: e, level: Level.error.value);
          if (!mounted) return;
          showErrorDialog(context, _lm.delete_user_error);
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ResponsiveEditView(
        title: _lm.users_edit,
        imageEditWidget: ImageEditField(
          fallbackImageUrl: "/api/users/${widget.userId}/pfp",
          imageUrl: _profileImageUrl,
          label: _lm.edit_user_profile_image,
          size: 256,
          onImageChanged: (image) {
            setState(() {
              _profileImageUrl = image;
            });
          },
        ),
        actions: [
          if ((_authState.user?.id == widget.userId && _authState.hasPermission(PermissionType.deleteOwnUser)) ||
            (_authState.user?.id != widget.userId && _authState.hasPermission(PermissionType.deleteUsers)))
          ElevatedButton.icon(
            onPressed: delete,
            icon: Icon(Icons.delete_forever),
            label: Text(_lm.dialog_delete),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: save,
            icon: Icon(Icons.save),
            label: Text(_lm.dialog_save),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          )
        ],
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_username,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _lm.edit_user_username_validation_empty;
              }
              if (value.length > 255) {
                return _lm.edit_user_username_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_display_name,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length > 255) {
                return _lm.edit_user_display_name_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_description,
            ),
            maxLines: null,
            minLines: 2,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_email,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length > 255) {
                return _lm.edit_user_email_validation_length;
              }
              if (!_emailRegexp.hasMatch(value)) {
                return _lm.edit_user_email_validation_invalid;
              }
              return null;
            },
          ),
          if (_authState.user?.isAdmin ?? false) ... [
            SwitchListTile(
              title: Text(_lm.edit_user_admin),
              value: _isAdmin,
              onChanged: (value) {
                setState(() {
                  _isAdmin = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(_lm.edit_user_active),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],

          SectionHeader(title: _lm.edit_user_change_password),

          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_password,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                if (widget.userId == null) return _lm.edit_user_password_validation_empty_new_user;
                return null;
              }
              if (value.length < 8) {
                return _lm.edit_user_password_validation_length;
              }
              if (value != _confirmPasswordController.text) {
                return _lm.edit_user_password_validation_mismatch;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: _lm.edit_user_password_confirm,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length < 8) {
                return _lm.edit_user_password_validation_length;
              }
              if (value != _passwordController.text) {
                return _lm.edit_user_password_validation_mismatch;
              }
              return null;
            },
          ),

          if (!(_authState.user?.isAdmin ?? false))
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: _lm.edit_user_password_old,
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (value.length < 8) {
                  return _lm.edit_user_password_validation_length;
                }
                return null;
              },
            ),
        ]
      ),
    );
  }
}