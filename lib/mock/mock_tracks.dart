import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/id_name.dart';

import '../dtos/track/minimal_track.dart';

List<MinimalTrack> getMockedMinimalTrackList(int count) {
  return List.filled(count, MinimalTrack(
    id: 0,
    title: BoneMock.title,
    artists: [
      IdName(id: 0, name: BoneMock.name)
    ],
    album: IdName(id: 0, name: BoneMock.name),
    coverId: 0,
    duration: 180000,
    uploader: IdName(id: 0, name: BoneMock.name)
  ));
}