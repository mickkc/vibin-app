import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/dtos/user/user_edit_data.dart';
import 'package:vibin_app/sections/section_header.dart';
import 'package:vibin_app/widgets/edit/image_edit_field.dart';
import 'package:vibin_app/widgets/edit/responsive_edit_view.dart';

import '../../api/api_manager.dart';
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

  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isAdmin = false;
  bool isActive = true;
  String? profileImageUrl;
  String? initialUsername;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();

  final emailRegexp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  final ApiManager apiManager = getIt<ApiManager>();
  final AuthState authState = getIt<AuthState>();
  late final lm = AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      apiManager.service.getUserById(widget.userId!).then((user) {
        setState(() {
          usernameController.text = user.username;
          displayNameController.text = user.displayName ?? "";
          descriptionController.text = user.description;
          emailController.text = user.email ?? "";
          isAdmin = user.isAdmin;
          isActive = user.isActive;
          initialUsername = user.username;
        });
      }).catchError((emailController) {
        if (!mounted) return;
        showErrorDialog(context, lm.edit_user_load_error);
      });
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {

      if (initialUsername != null && initialUsername != usernameController.text) {
        final doesUserNameExist = await apiManager.service.checkUsernameExists(
          usernameController.text
        );

        if (doesUserNameExist.success) {
          if (!mounted) return;
          showErrorDialog(context, lm.edit_user_username_validation_already_exists);
          return;
        }
      }

      final editData = UserEditData(
        username: usernameController.text,
        displayName: displayNameController.text.isEmpty ? null : displayNameController.text,
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        isAdmin: isAdmin,
        isActive: isActive,
        password: passwordController.text.isEmpty ? null : passwordController.text,
        oldPassword: currentPasswordController.text.isEmpty ? null : currentPasswordController.text,
        profilePictureUrl: profileImageUrl,
      );

      final savedUser = widget.userId == null
        ? await apiManager.service.createUser(editData)
        : await apiManager.service.updateUser(widget.userId!, editData);

      if (profileImageUrl != null) {
        imageCache.clear();
        imageCache.clearLiveImages();
      }

      widget.onSave(savedUser);
    }
    catch (e) {
      log("Failed to save user: $e", error: e, level: Level.error.value);
      if (!mounted) return;
      showErrorDialog(context, lm.edit_user_save_error);
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: ResponsiveEditView(
        title: lm.users_edit,
        imageEditWidget: ImageEditField(
          fallbackImageUrl: "/api/users/${widget.userId}/pfp",
          imageUrl: profileImageUrl,
          label: lm.edit_user_profile_image,
          size: 256,
          onImageChanged: (image) {
            setState(() {
              profileImageUrl = image;
            });
          },
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: (){},
            icon: Icon(Icons.delete_forever),
            label: Text(lm.dialog_delete),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
          ElevatedButton.icon(
            onPressed: save,
            icon: Icon(Icons.save),
            label: Text(lm.dialog_save),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          )
        ],
        children: [
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: lm.edit_user_username,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return lm.edit_user_username_validation_empty;
              }
              if (value.length > 255) {
                return lm.edit_user_username_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: displayNameController,
            decoration: InputDecoration(
              labelText: lm.edit_user_display_name,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length > 255) {
                return lm.edit_user_display_name_validation_length;
              }
              return null;
            },
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: lm.edit_user_description,
            ),
            maxLines: null,
            minLines: 2,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: lm.edit_user_email,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length > 255) {
                return lm.edit_user_email_validation_length;
              }
              if (!emailRegexp.hasMatch(value)) {
                return lm.edit_user_email_validation_invalid;
              }
              return null;
            },
          ),
          if (authState.user?.isAdmin ?? false) ... [
            SwitchListTile(
              title: Text(lm.edit_user_admin),
              value: isAdmin,
              onChanged: (value) {
                setState(() {
                  isAdmin = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(lm.edit_user_active),
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),
          ],

          SectionHeader(title: lm.edit_user_change_password),

          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: lm.edit_user_password,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length < 8) {
                return lm.edit_user_password_validation_length;
              }
              if (value != confirmPasswordController.text) {
                return lm.edit_user_password_validation_mismatch;
              }
              return null;
            },
          ),
          TextFormField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: lm.edit_user_password_confirm,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (value.length < 8) {
                return lm.edit_user_password_validation_length;
              }
              if (value != passwordController.text) {
                return lm.edit_user_password_validation_mismatch;
              }
              return null;
            },
          ),

          if (!(authState.user?.isAdmin ?? false))
            TextFormField(
              controller: currentPasswordController,
              decoration: InputDecoration(
                labelText: lm.edit_user_password_old,
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (value.length < 8) {
                  return lm.edit_user_password_validation_length;
                }
                return null;
              },
            ),
        ]
      ),
    );
  }
}