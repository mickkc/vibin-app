import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/id_name.dart';
import 'package:vibin_app/dtos/track/related_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/mock/mock_album.dart';

import '../dtos/track/minimal_track.dart';
import 'mock_artists.dart';

Track getMockedTrack() {
  return Track(
    id: 0,
    title: BoneMock.title,
    comment: BoneMock.subtitle,
    album: getMockedAlbum(),
    artists: getMockedArtistList(2),
    explicit: true,
    path: "/path/to/track/track.mp3",
    tags: [],
    hasLyrics: true,
    bitrate: 320,
    channels: 2,
    discCount: 1,
    discNumber: 1,
    duration: 180000,
    sampleRate: 44000,
    trackCount: 5,
    trackNumber: 3,
    year: 2020,
    createdAt: 1779115233,
    updatedAt: 1779115233
  );
}

List<Track> getMockedTrackList(int count) {
  return List.filled(count, getMockedTrack());
}

MinimalTrack getMockedMinimalTrack() {
  return MinimalTrack(
      id: 0,
      title: BoneMock.title,
      artists: [
        IdName(id: 0, name: BoneMock.name)
      ],
      album: IdName(id: 0, name: BoneMock.name),
      duration: 180000,
      uploader: IdName(id: 0, name: BoneMock.name)
  );
}

List<MinimalTrack> getMockedMinimalTrackList(int count) {
  return List.filled(count, getMockedMinimalTrack());
}

List<RelatedTrack> getMockedRelatedTrackList(int count) {
  return List.filled(count, RelatedTrack(
    track: getMockedMinimalTrack(),
    relationDescription: BoneMock.subtitle
  ));
}