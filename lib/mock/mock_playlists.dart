import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/user/user.dart';

import '../dtos/playlist/playlist.dart';

List<Playlist> getMockedPlaylistList(int count) {
  return List.filled(count, Playlist(
    id: 0,
    name: BoneMock.title,
    description: BoneMock.subtitle,
    public: true,
    collaborators: [
      User(
        0, BoneMock.name, BoneMock.name, BoneMock.subtitle,
        0, BoneMock.email,
        true, false,
        1779115233,
        1779115233, 1779115233
      )
    ],
    vibedef: null,
    owner: User(
      0, BoneMock.name, BoneMock.name, BoneMock.subtitle,
      0, BoneMock.email,
      true, false,
      1779115233,
      1779115233, 1779115233
    ),
    createdAt: 1779115233,
    updatedAt: 1779115233
  ));
}