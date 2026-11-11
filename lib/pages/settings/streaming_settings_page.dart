import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../../settings/enums/metadata_image_size.dart';
import '../../settings/setting_definitions.dart';
import '../../widgets/settings/bool_settings_field.dart';
import '../../widgets/settings/enum_settings_field.dart';
import '../../widgets/settings/int_settings_field.dart';
import '../../widgets/settings/settings_title.dart';

class StreamingSettingsPage extends StatelessWidget {

  const StreamingSettingsPage({ super.key });

  @override
  Widget build(BuildContext context) {

    final lm = AppLocalizations.of(context)!;

    return ListView(
      children: [
        SettingsTitle(
          title: lm.settings_app_streaming_title,
          icon: Icons.audio_file,
          heroTag: "settings-streaming",
        ),

        BoolSettingsField(
          settingsKey: Settings.enableTranscoding,
          title: lm.settings_app_enable_transcoding_title,
          description: lm.settings_app_enable_transcoding_description,
          icon: Icons.sync_alt,
        ),

        EnumSettingsField(
          settingKey: Settings.preferredStreamingFormat,
          title: lm.settings_app_preferred_streaming_format_title,
          description: lm.settings_app_preferred_streaming_format_description,
          icon: Icons.audiotrack,
          optionLabel: (option) => option.name,
        ),

        IntSettingsInputField(
          settingsKey: Settings.preferredStreamingBitrate,
          label: lm.settings_app_preferred_streaming_bitrate_title,
          description: lm.settings_app_preferred_streaming_bitrate_description,
          icon: Icons.speed,
          min: 64,
          max: 320,
        ),

        BoolSettingsField(
          settingsKey: Settings.enableVolumeNormalization,
          title: lm.settings_app_normalize_volume_title,
          description: lm.settings_app_normalize_volume_description,
          icon: Icons.volume_up,
        ),

        BoolSettingsField(
          settingsKey: Settings.embedImagesAsBase64,
          title: lm.settings_app_embed_images_as_base64_title,
          description: lm.settings_app_embed_images_as_base64_description,
          icon: Icons.image,
        ),

        EnumSettingsField(
          settingKey: Settings.metadataImageSize,
          title: lm.settings_app_metadata_image_size_title,
          description: lm.settings_app_metadata_image_size_description,
          icon: Icons.image_search,
          optionLabel: (option) {
            return switch (option) {
              MetadataImageSize.small => lm.settings_app_metadata_image_size_small,
              MetadataImageSize.medium => lm.settings_app_metadata_image_size_medium,
              MetadataImageSize.large => lm.settings_app_metadata_image_size_large,
            };
          },
        ),
      ],
    );
  }
}