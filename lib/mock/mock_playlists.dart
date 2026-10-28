import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/id_name.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/playlist/playlist_track.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/mock/mock_tracks.dart';

import '../dtos/playlist/playlist.dart';

Playlist getMockedPlaylist() {
  return Playlist(
    id: 0,
    name: BoneMock.title,
    description: BoneMock.subtitle,
    public: true,
    collaborators: [
      User(
          0, BoneMock.name, BoneMock.name, BoneMock.subtitle,
          null, BoneMock.email, true,
          true, false,
          1779115233,
          1779115233, 1779115233
      )
    ],
    vibedef: null,
    owner: User(
        0, BoneMock.name, BoneMock.name, BoneMock.subtitle,
        null, BoneMock.email, true,
        true, false,
        1779115233,
        1779115233, 1779115233
    ),
    createdAt: 1779115233,
    updatedAt: 1779115233
  );
}

List<Playlist> getMockedPlaylistList(int count) {
  return List.filled(count, getMockedPlaylist());
}

List<PlaylistTrack> getMockedPlaylistTrackList(int count) {
  return List.filled(count, PlaylistTrack(
    track: getMockedMinimalTrack(),
    position: 0,
    addedBy: IdName(id: 0, name: BoneMock.name),
    addedAt: 1779115233
  ));
}

PlaylistData getMockedPlaylistData() {
  return PlaylistData(
    playlist: getMockedPlaylist(),
    tracks: getMockedPlaylistTrackList(10)
  );
}