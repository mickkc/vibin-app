import '../dtos/permission_type.dart';
import '../l10n/app_localizations.dart';

extension PermissionsTranslator on AppLocalizations {

  String translatePermission(PermissionType type) {
    return switch (type) {
      PermissionType.changeServerSettings => permissions_change_server_settings,
      PermissionType.changeOwnUserSettings => permissions_change_own_settings,
      PermissionType.managePermissions => permissions_manage_permissions,

      PermissionType.viewTracks => permissions_view_tracks,
      PermissionType.streamTracks => permissions_stream_tracks,
      PermissionType.manageTracks => permissions_manage_tracks,
      PermissionType.uploadTracks => permissions_upload_tracks,
      PermissionType.downloadTracks => permissions_download_tracks,
      PermissionType.deleteTracks => permissions_delete_tracks,

      PermissionType.viewAlbums => permissions_view_albums,
      PermissionType.manageAlbums => permissions_manage_albums,
      PermissionType.deleteAlbums => permissions_delete_albums,

      PermissionType.viewArtists => permissions_view_artists,
      PermissionType.manageArtists => permissions_manage_artists,
      PermissionType.deleteArtists => permissions_delete_artists,

      PermissionType.viewPlaylists => permissions_view_playlists,
      PermissionType.managePlaylists => permissions_manage_playlists,
      PermissionType.createPrivatePlaylists => permissions_create_private_playlists,
      PermissionType.createPublicPlaylists => permissions_create_public_playlists,
      PermissionType.deleteOwnPlaylists => permissions_delete_own_playlists,
      PermissionType.editCollaborativePlaylists => permissions_edit_collaborative_playlists,
      PermissionType.deleteCollaborativePlaylists => permissions_delete_collaborative_playlists,
      PermissionType.allowCollaboration => permissions_allow_collaboration,

      PermissionType.viewUsers => permissions_view_users,
      PermissionType.manageUsers => permissions_manage_users,
      PermissionType.manageOwnUser => permissions_manage_own_user,
      PermissionType.deleteUsers => permissions_delete_users,
      PermissionType.deleteOwnUser => permissions_delete_own_user,
      PermissionType.createUsers => permissions_create_users,

      PermissionType.viewTags => permissions_view_tags,
      PermissionType.manageTags => permissions_manage_tags,
      PermissionType.deleteTags => permissions_delete_tags,
      PermissionType.createTags => permissions_create_tags,

      PermissionType.manageSessions => permissions_manage_sessions,
      PermissionType.manageTasks => permissions_manage_tasks,

      _ => type.value
    };
  }
}