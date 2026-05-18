import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/album/album.dart';

import 'mock_artists.dart';

Album getMockedAlbum() {
  return Album(
    id: 0,
    title: BoneMock.title,
    description: BoneMock.subtitle,
    artists: getMockedArtistList(2),
    trackCount: 7,
    createdAt: 1779115233,
    updatedAt: 1779115233
  );
}