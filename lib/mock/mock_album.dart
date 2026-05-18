import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/mock/mock_tracks.dart';

import 'mock_artists.dart';

Album getMockedAlbum() {
  return Album(
    id: 0,
    title: BoneMock.title,
    description: BoneMock.subtitle,
    artists: getMockedArtistList(2),
    trackCount: 7,
    year: 2020,
    single: false,
    createdAt: 1779115233,
    updatedAt: 1779115233
  );
}

List<Album> getMockedAlbumList(int count) {
  return List.filled(count, getMockedAlbum());
}

AlbumData getMockedAlbumData() {
  return AlbumData(
    album: getMockedAlbum(),
    tracks: getMockedTrackList(10)
  );
}