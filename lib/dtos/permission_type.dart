enum PermissionType {

  changeServerSettings("change_server_settings"),
  managePermissions("manage_permissions"),

  viewTracks("view_tracks"),
  streamTracks("stream_tracks"),
  manageTracks("manage_tracks"),
  uploadTracks("upload_tracks"),
  downloadTracks("download_tracks"),
  deleteTracks("delete_tracks"),

  viewAlbums("view_albums"),
  manageAlbums("manage_albums"),
  deleteAlbums("delete_albums"),

  viewArtists("view_artists"),
  manageArtists("manage_artists"),
  deleteArtists("delete_artists"),

  viewPlaylists("view_playlists"),
  managePlaylists("manage_playlists"),
  createPrivatePlaylists("create_private_playlists"),
  createPublicPlaylists("create_public_playlists"),
  deleteOwnPlaylists("delete_own_playlists"),
  editCollaborativePlaylists("edit_collaborative_playlists"),
  deleteCollaborativePlaylists("delete_collaborative_playlists"),
  allowCollaboration("allow_collaboration"),

  viewUsers("view_users"),
  manageUsers("manage_users"),
  manageOwnUser("edit_own_user"),
  deleteUsers("delete_users"),
  deleteOwnUser("delete_own_user"),
  createUsers("create_users"),

  viewTags("view_tags"),
  manageTags("manage_tags"),
  deleteTags("delete_tags"),
  createTags("create_tags"),

  manageSessions("manage_sessions"),
  manageTasks("manage_tasks");

  final String value;
  const PermissionType(this.value);
}