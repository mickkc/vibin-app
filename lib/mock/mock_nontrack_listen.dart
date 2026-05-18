import 'package:skeletonizer/skeletonizer.dart';

import '../dtos/non_track_listen.dart';

List<NonTrackListen> getMockedNonTrackListenList(int count) {
  return List.filled(count, NonTrackListen(
    key: "ALBUM",
    value: {
      "id": 0,
      "title": BoneMock.title,
      "description": BoneMock.subtitle,
      "artists": [
        {
          "id": 0,
          "name": BoneMock.title,
          "description": BoneMock.subtitle,
          "imageId": 0,
          "createdAt": 1779115233,
          "updatedAt": 1779115233
        }
      ],
      "trackCount": 7,
      "single": false,
      "createdAt": 1779115233,
      "updatedAt": 1779115233
    }
  ));
}