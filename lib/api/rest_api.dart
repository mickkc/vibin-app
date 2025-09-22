
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/artist/artist_metadata.dart';
import 'package:vibin_app/dtos/login_result.dart';
import 'package:vibin_app/dtos/metadata_sources.dart';
import 'package:vibin_app/dtos/non_track_listen.dart';
import 'package:vibin_app/dtos/server_check.dart';
import 'package:vibin_app/dtos/tag.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/pagination/album_pagination.dart';
import 'package:vibin_app/dtos/pagination/artist_pagination.dart';
import 'package:vibin_app/dtos/pagination/minimal_track_pagination.dart';
import 'package:vibin_app/dtos/pagination/playlist_pagination.dart';
import 'package:vibin_app/dtos/permission_granted.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/success.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/dtos/track/track_edit_data.dart';
import 'package:vibin_app/dtos/track/track_info_metadata.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/dtos/user/user_edit_data.dart';

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

  // Albums

  @GET("/api/albums")
  Future<AlbumPagination> getAlbums(@Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/api/albums/{id}")
  Future<AlbumData> getAlbum(@Path("id") int id);

  @GET("/api/albums/{id}/cover")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getAlbumCover(@Path("id") int id, @Query("quality") String quality);

  // Artists

  @GET("/api/artists")
  Future<ArtistPagination> getArtists(@Query("page") int page, @Query("pageSize") int pageSize);

  @POST("/api/artists")
  Future<Artist> createArtist(@Body() ArtistEditData artistData);

  @GET("/api/artists/{id}")
  Future<Artist> getArtist(@Path("id") int id);

  @DELETE("/api/artists/{id}")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> deleteArtist(@Path("id") int id);

  @GET("/api/artists/{id}/image")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getArtistImage(@Path("id") int id, @Query("quality") String quality);

  // Metadata

  @GET("/api/metadata/providers")
  Future<MetadataSources> getMetadataProviders();

  @GET("/api/metadata/track")
  Future<List<TrackInfoMetadata>> searchTrackMetadata(@Query("q") String query, @Query("provider") String provider);

  @GET("/api/metadata/artists")
  Future<List<ArtistMetadata>> searchArtistMetadata(@Query("q") String query, @Query("provider") String provider);

  // Permissions

  @GET("/api/permissions")
  Future<List<String>> getUserPermissions();

  @GET("/api/permissions/{userId}")
  Future<List<String>> getPermissionsForUser(@Path("userId") int userId);

  @PUT("/api/permissions/{userId}")
  Future<PermissionGranted> updateUserPermissions(@Path("userId") int userId, @Query("permissionId") String permissionId);

  // Playlists

  @GET("/api/playlists")
  Future<PlaylistPagination> getPlaylists(@Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/api/playlists/{id}")
  Future<PlaylistData> getPlaylist(@Path("id") int id);

  @POST("/api/playlists")
  Future<Playlist> createPlaylist(@Body() PlaylistData data);

  @PUT("/api/playlists/{id}")
  Future<Playlist> updatePlaylist(@Path("id") int id, @Body() PlaylistData data);

  @DELETE("/api/playlists/{id}")
  Future<Success> deletePlaylist(@Path("id") int id);

  @GET("/api/playlists/{id}/image")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getPlaylistImage(@Path("id") int id, @Query("quality") String quality);

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
  Future<List<MinimalTrack>> getMostListenedTracks(@Path("num") int num, @Query("since") int since);

  @GET("/api/stats/artists/top{num}")
  Future<List<Artist>> getTopListenedArtists(@Path("num") int num, @Query("since") int since);

  @GET("/api/stats/albums/top{num}")
  Future<List<User>> getTopListenedAlbums(@Path("num") int num, @Query("since") int since);

  @GET("/api/stats/tags/top{num}")
  Future<List<Tag>> getTopListenedTags(@Path("num") int num, @Query("since") int since);

  @GET("/api/stats/nontracks/top{num}")
  Future<List<NonTrackListen>> getTopListenedNonTrackItems(@Path("num") int num, @Query("since") int since);

  @POST("/api/stats/listen/TRACK/{trackId}")
  Future<Success> reportTrackListen(@Path("trackId") int trackId);

  @POST("/api/stats/listen/ALBUM/{albumId}")
  Future<Success> reportAlbumListen(@Path("albumId") int albumId);

  @POST("/api/stats/listen/ARTIST/{artistId}")
  Future<Success> reportArtistListen(@Path("artistId") int artistId);

  @POST("/api/stats/listen/PLAYLIST/{playlistId}")
  Future<Success> reportPlaylistListen(@Path("playlistId") int playlistId);

  // Tracks

  @GET("/api/tracks")
  Future<MinimalTrackPagination> getTracks(@Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/api/tracks/{id}")
  Future<Track> getTrack(@Path("id") int id);

  @PUT("/api/tracks/{id}")
  Future<Track> updateTrack(@Path("id") int id, @Body() TrackEditData data);

  @DELETE("/api/tracks/{id}")
  Future<Success> deleteTrack(@Path("id") int id);

  @GET("/api/tracks/search")
  Future<MinimalTrackPagination> searchTracks(@Query("query") String query, @Query("advanced") bool advanced, @Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/api/tracks/{id}/stream")
  @DioResponseType(ResponseType.stream)
  Future<HttpResponse<List<int>>> streamTrack(@Path("id") int id);

  @GET("/api/tracks/{id}/cover")
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getTrackCover(@Path("id") int id, @Query("quality") String quality);

  @GET("/api/tracks/random")
  Future<List<MinimalTrack>> getRandomTracks(@Query("limit") int limit);

  // Users

  @GET("/api/users")
  Future<List<User>> getUsers();

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
}