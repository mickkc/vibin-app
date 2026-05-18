import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/artist/artist.dart';

List<Artist> getMockedArtistList(int count) {
  return List.filled(count, Artist(
    id: 0,
    name: BoneMock.name,
    description: BoneMock.subtitle,
    createdAt: 1779115233,
    updatedAt: 1779115233
  ));
}