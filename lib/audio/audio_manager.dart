import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/api/client_data.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/main.dart';

class AudioManager extends BaseAudioHandler with QueueHandler, SeekHandler {

  late final ApiManager apiManager;
  late final AudioPlayer audioPlayer;
  late final ClientData clientData;

  AudioManager() {
    apiManager = getIt<ApiManager>();
    clientData = getIt<ClientData>();
    audioPlayer = AudioPlayer();
  }

  Future<void> playPlaylist(Playlist playlist) async {
    await audioPlayer.stop();
    final playlistData = await apiManager.service.getPlaylist(playlist.id);
    await playPlaylistData(playlistData, null);
  }

  Future<void> playPlaylistData(PlaylistData data, int? preferredTrackId) async {

    var tracks = data.tracks.map((i) => i.track).toList();
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    final mediaToken = await clientData.getMediaToken();
    final sources = data.tracks.map((track) => fromTrack(track.track, mediaToken)).toList();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await audioPlayer.play();
    await apiManager.service.reportPlaylistListen(data.playlist.id);
  }

  Future<void> playAlbum(Album album) async {
    await audioPlayer.stop();
    final albumData = await apiManager.service.getAlbum(album.id);
    await playAlbumData(albumData, null);
  }

  Future<void> playAlbumData(AlbumData data, int? preferredTrackId) async {
    var tracks = data.tracks;
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    final mediaToken = await clientData.getMediaToken();
    final sources = data.tracks.map((track) => fromMinimalTrack(track, mediaToken)).toList();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await audioPlayer.play();
    await apiManager.service.reportAlbumListen(data.album.id);
  }

  Future<void> playMinimalTrack(MinimalTrack track) async {
    final mediaToken = await clientData.getMediaToken();
    final source = fromMinimalTrack(track, mediaToken);
    await audioPlayer.stop();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    audioPlayer.play();
  }

  Future<void> playTrack(Track track) async {
    final mediaToken = await clientData.getMediaToken();
    final source = fromTrack(track, mediaToken);
    await audioPlayer.stop();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    audioPlayer.play();
  }

  MediaItem? getCurrentMediaItem() {
    final current = audioPlayer.sequenceState.currentSource;
    if (current == null) return null;
    final tag = current.tag;
    if (tag is MediaItem) {
      return tag;
    }
    return null;
  }

  AudioSource fromMinimalTrack(MinimalTrack track, String mediaToken) {
    final url = "${apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/stream?mediaToken=$mediaToken";
    final artUrl = "${apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/cover?mediaToken=$mediaToken";
    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.name,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: Uri.parse(artUrl),
      artHeaders: {
        'Authorization': 'Bearer ${apiManager.accessToken}',
      }
    );
    return AudioSource.uri(
        Uri.parse(url),
        tag: mi,
        headers: {
          'Authorization': 'Bearer ${apiManager.accessToken}',
        }
    );
  }

  AudioSource fromTrack(Track track, String mediaToken) {
    final url = "${apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/stream?mediaToken=$mediaToken";
    final artUrl = "${apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/cover?mediaToken=$mediaToken";
    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.title,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: Uri.parse(artUrl),
      artHeaders: {
        'Authorization': 'Bearer ${apiManager.accessToken}',
      }
    );
    return AudioSource.uri(
      Uri.parse(url),
      tag: mi,
      headers: {
        'Authorization': 'Bearer ${apiManager.accessToken}',
      }
    );
  }

  static Future<void> initBackgroundTask() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'wtf.ndu.vibin.channel.audio',
      androidNotificationChannelName: 'Vibin Audio Playback',
      androidNotificationOngoing: true,
    );
  }
}