
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/album/album_edit_data.dart';
import 'package:vibin_app/dtos/album/album_info_metadata.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/artist/artist_metadata.dart';
import 'package:vibin_app/dtos/artist_dicography.dart';
import 'package:vibin_app/dtos/login_result.dart';
import 'package:vibin_app/dtos/lyrics.dart';
import 'package:vibin_app/dtos/lyrics_metadata.dart';
import 'package:vibin_app/dtos/media_token_response.dart';
import 'package:vibin_app/dtos/metadata_sources.dart';
import 'package:vibin_app/dtos/non_track_listen.dart';
import 'package:vibin_app/dtos/pagination/album_pagination.dart';
import 'package:vibin_app/dtos/pagination/artist_pagination.dart';
import 'package:vibin_app/dtos/pagination/minimal_track_pagination.dart';
import 'package:vibin_app/dtos/pagination/playlist_pagination.dart';
import 'package:vibin_app/dtos/pagination/user_pagination.dart';
import 'package:vibin_app/dtos/permission_granted.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/playlist/playlist_edit_data.dart';
import 'package:vibin_app/dtos/server_check.dart';
import 'package:vibin_app/dtos/success.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/dtos/tags/tag_edit_data.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/dtos/track/track_edit_data.dart';
import 'package:vibin_app/dtos/track/track_info_metadata.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/dtos/user/user_edit_data.dart';
import 'package:vibin_app/dtos/user_activity.dart';

import '../dtos/artist/artist_edit_data.dart';

part 'rest_api.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/api/check")
  Future<ServerCheck> checkServer();

  // Authentication

  @POST("/api/auth/login")
  Future<LoginResult> login(
    @Query("username") String username,
    @Query("password") String password,
  );

  @POST("/api/auth/validate")
  Future<LoginResult> validateAuthorization();

  @POST("/api/auth/logout")
  Future<Success> logout();

  @POST("/api/auth/media/token")
  Future<MediaTokenResponse> createMediaToken(@Query("deviceId") String deviceId);

  @GET("/api/auth/media")
  Future<Success> checkMediaToken(@Query("mediaToken") String mediaToken);

  @DELETE("/api/auth/media/token")
  Future<Success> invalidateMediaToken(@Query("deviceId") String deviceId);

  // Albums

  @GET("/api/albums")
  Future<AlbumPagination> getAlbums(@Query("page") int page, @Query("pageSize") int? pageSize, @Query("query") String? query, @Query("showSingles") bool? showSingles);

  @GET("/api/albums/{id}")
  Future<AlbumData> getAlbum(@Path("id") int id);

  @PUT("/api/albums/{id}")
  Future<Album> updateAlbum(@Path("id") int id, @Body() AlbumEditData data);

  @GET("/api/albums/{id}/cover")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getAlbumCover(@Path("id") int id, @Query("quality") String quality);

  @GET("/api/albums/autocomplete")
  Future<List<String>> autocompleteAlbums(@Query("query") String query, @Query("limit") int? limit);

  @GET("/api/albums/artists/{id}")
  Future<List<ArtistDiscography>> getArtistDiscography(@Path("id") int artistId);

  // Artists

  @GET("/api/artists")
  Future<ArtistPagination> getArtists(@Query("page") int page, @Query("pageSize") int? pageSize, @Query("query") String? query);

  @POST("/api/artists")
  Future<Artist> createArtist(@Body() ArtistEditData artistData);

  @PUT("/api/artists/{id}")
  Future<Artist> updateArtist(@Path("id") int id, @Body() ArtistEditData data);

  @GET("/api/artists/{id}")
  Future<Artist> getArtist(@Path("id") int id);

  @DELETE("/api/artists/{id}")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> deleteArtist(@Path("id") int id);

  @GET("/api/artists/{id}/image")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getArtistImage(@Path("id") int id, @Query("quality") String quality);

  @GET("/api/artists/autocomplete")
  Future<List<String>> autocompleteArtists(@Query("query") String query, @Query("limit") int? limit);

  // Metadata

  @GET("/api/metadata/providers")
  Future<MetadataSources> getMetadataProviders();

  @GET("/api/metadata/track")
  Future<List<TrackInfoMetadata>> searchTrackMetadata(@Query("q") String query, @Query("provider") String provider);

  @GET("/api/metadata/album")
  Future<List<AlbumInfoMetadata>> searchAlbumMetadata(@Query("q") String query, @Query("provider") String provider);

  @GET("/api/metadata/artist")
  Future<List<ArtistMetadata>> searchArtistMetadata(@Query("q") String query, @Query("provider") String provider);

  @GET("/api/metadata/lyrics")
  Future<List<LyricsMetadata>> searchLyricsMetadata(@Query("q") String query, @Query("provider") String provider);

  // Permissions

  @GET("/api/permissions")
  Future<List<String>> getUserPermissions();

  @GET("/api/permissions/{userId}")
  Future<List<String>> getPermissionsForUser(@Path("userId") int userId);

  @PUT("/api/permissions/{userId}")
  Future<PermissionGranted> updateUserPermissions(@Path("userId") int userId, @Query("permissionId") String permissionId);

  // Playlists

  @GET("/api/playlists")
  Future<PlaylistPagination> getPlaylists(@Query("page") int page, @Query("pageSize") int? pageSize, @Query("query") String? query, @Query("onlyOwn") bool? onlyOwn);

  @GET("/api/playlists/{id}")
  Future<PlaylistData> getPlaylist(@Path("id") int id);

  @POST("/api/playlists")
  Future<Playlist> createPlaylist(@Body() PlaylistEditData data);

  @PUT("/api/playlists/{id}")
  Future<Playlist> updatePlaylist(@Path("id") int id, @Body() PlaylistEditData data);

  @DELETE("/api/playlists/{id}")
  Future<Success> deletePlaylist(@Path("id") int id);

  @GET("/api/playlists/{id}/image")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getPlaylistImage(@Path("id") int id, @Query("quality") String quality);

  @GET("/api/playlists/random")
  Future<List<Playlist>> getRandomPlaylists(@Query("limit") int? limit);

  @GET("/api/playlists/users/{id}")
  Future<List<Playlist>> getPlaylistsForUser(@Path("id") int userId);

  // Playlist Tracks

  @POST("/api/playlists/{playlistId}/tracks")
  Future<Success> addTrackToPlaylist(@Path("playlistId") int playlistId, @Query("trackId") int trackId);

  @DELETE("/api/playlists/{playlistId}/tracks")
  Future<Success> removeTrackFromPlaylist(@Path("playlistId") int playlistId, @Query("trackId") int trackId);

  @PUT("/api/playlists/{playlistId}/tracks")
  Future<Success> reorderPlaylistTracks(@Path("playlistId") int playlistId, @Query("trackId") int trackId, @Query("newPosition") int newPosition);

  @GET("/api/playlists/containing/{trackId}")
  Future<List<Playlist>> getPlaylistsContainingTrack(@Path("trackId") int trackId);

  // Statistics

  @GET("/api/stats/recent")
  Future<List<MinimalTrack>> getRecentListenedTracks(@Query("limit") int limit);

  @GET("/api/stats/recent/nontracks")
  Future<List<NonTrackListen>> getRecentListenedNonTrackItems(@Query("limit") int limit);

  @GET("/api/stats/tracks/top{num}")
  Future<List<MinimalTrack>> getTopListenedTracks(@Path("num") int num, @Query("since") int? since);

  @GET("/api/stats/artists/top{num}")
  Future<List<Artist>> getTopListenedArtists(@Path("num") int num, @Query("since") int? since);

  @GET("/api/stats/albums/top{num}")
  Future<List<User>> getTopListenedAlbums(@Path("num") int num, @Query("since") int? since);

  @GET("/api/stats/tags/top{num}")
  Future<List<Tag>> getTopListenedTags(@Path("num") int num, @Query("since") int? since);

  @GET("/api/stats/nontracks/top{num}")
  Future<List<NonTrackListen>> getTopListenedNonTrackItems(@Path("num") int num, @Query("since") int? since);

  @GET("/api/stats/global_nontracks/top{num}")
  Future<List<NonTrackListen>> getTopListenedGlobalNonTrackItems(@Path("num") int num, @Query("since") int? since);

  @POST("/api/stats/listen/TRACK/{trackId}")
  Future<Success> reportTrackListen(@Path("trackId") int trackId);

  @POST("/api/stats/listen/ALBUM/{albumId}")
  Future<Success> reportAlbumListen(@Path("albumId") int albumId);

  @POST("/api/stats/listen/ARTIST/{artistId}")
  Future<Success> reportArtistListen(@Path("artistId") int artistId);

  @POST("/api/stats/listen/PLAYLIST/{playlistId}")
  Future<Success> reportPlaylistListen(@Path("playlistId") int playlistId);

  @GET("/api/stats/users/{id}/activity")
  Future<UserActivity> getUserActivity(@Path("id") int userId, @Query("since") int? since, @Query("limit") int? limit);

  // Tags

  @GET("/api/tags")
  Future<List<Tag>> getAllTags(@Query("query") String? query, @Query("limit") int? limit);

  @PUT("/api/tags/{id}")
  Future<Tag> updateTag(@Path("id") int id, @Body() TagEditData data);

  @POST("/api/tags")
  Future<Tag> createTag(@Body() TagEditData data);

  @DELETE("/api/tags/{id}")
  Future<Success> deleteTag(@Path("id") int id);

  @GET("/api/tags/named/{name}")
  Future<Tag> getTagByName(@Path("name") String name);

  @GET("/api/tags/autocomplete")
  Future<List<String>> autocompleteTags(@Query("query") String query, @Query("limit") int? limit);

  @GET("/api/tags/check/{name}")
  Future<Success> checkTagName(@Path("name") String name);

  // Tracks

  @GET("/api/tracks")
  Future<MinimalTrackPagination> getTracks(@Query("page") int page, @Query("pageSize") int? pageSize);

  @GET("/api/tracks/{id}")
  Future<Track> getTrack(@Path("id") int id);

  @PUT("/api/tracks/{id}")
  Future<Track> updateTrack(@Path("id") int id, @Body() TrackEditData data);

  @DELETE("/api/tracks/{id}")
  Future<Success> deleteTrack(@Path("id") int id);

  @GET("/api/tracks/search")
  Future<MinimalTrackPagination> searchTracks(@Query("query") String query, @Query("advanced") bool advanced, @Query("page") int page, @Query("pageSize") int? pageSize);

  @GET("/api/tracks/{id}/stream")
  @DioResponseType(ResponseType.stream)
  Future<HttpResponse<List<int>>> streamTrack(@Path("id") int id);

  @GET("/api/tracks/{id}/cover")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getTrackCover(@Path("id") int id, @Query("quality") String quality);

  @GET("/api/tracks/random")
  Future<List<MinimalTrack>> getRandomTracks(@Query("limit") int limit);

  @GET("/api/tracks/{trackId}/related")
  Future<List<MinimalTrack>> getRelatedTracks(@Path("trackId") int trackId, @Query("limit") int limit);

  @GET("/api/tracks/newest")
  Future<List<MinimalTrack>> getNewestTracks(@Query("limit") int limit);

  @GET("/api/tracks/{id}/lyrics")
  Future<Lyrics> getTrackLyrics(@Path("id") int id);

  @GET("/api/tracks/{id}/lyrics/check")
  Future<Success> checkTrackHasLyrics(@Path("id") int id);

  @GET("/api/tracks/artists/{id}")
  Future<List<Track>> getTracksByArtist(@Path("id") int artistId);

  // Users

  @GET("/api/users")
  Future<UserPagination> getUsers(@Query("page") int page, @Query("pageSize") int? pageSize, @Query("query") String? query);

  @GET("/api/users/me")
  Future<User> getCurrentUser();

  @GET("/api/users/{userId}")
  Future<User> getUserById(@Path("userId") int id);

  @POST("/api/users")
  Future<User> createUser(@Body() UserEditData data);

  @PUT("/api/users/{userId}")
  Future<User> updateUser(@Path("userId") int id, @Body() UserEditData data);

  @DELETE("/api/users/{userId}")
  Future<Success> deleteUser(@Path("userId") int id, @Query("deleteData") bool deleteData);

  @GET("/api/users/{userId}/pfp")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getUserProfilePicture(@Path("userId") int id);

  @GET("/api/users/username/{username}/exists")
  Future<Success> checkUsernameExists(@Path("username") String username);
}