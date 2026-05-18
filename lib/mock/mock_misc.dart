import 'package:vibin_app/mock/mock_album.dart';
import 'package:vibin_app/mock/mock_artists.dart';
import 'package:vibin_app/mock/mock_playlists.dart';
import 'package:vibin_app/mock/mock_tracks.dart';
import 'package:vibin_app/mock/mock_user.dart';

import '../dtos/global_stats.dart';
import '../widgets/entity_card.dart';

GlobalStats getMockedGlobalStats() {
  return GlobalStats(
    totalTracks: 9999,
    totalTrackDuration: 274031,
    totalArtists: 999,
    totalAlbums: 999,
    totalPlaylists: 99,
    totalUsers: 99,
    totalPlays: 99999
  );
}

List<dynamic> getMockedForType(EntityCardType type, int count) {
  switch (type) {
    case EntityCardType.album:
      return getMockedAlbumList(count);
    case EntityCardType.artist:
      return getMockedArtistList(count);
    case EntityCardType.playlist:
      return getMockedPlaylistList(count);
    case EntityCardType.track:
      return getMockedTrackList(count);
    case EntityCardType.user:
      return getMockedUserList(count);
    default:
      return [];
  }
}

class MockPagination {
  List<dynamic> items;
  int total;
  int pageSize;
  int currentPage;

  MockPagination(this.items, this.total, this.pageSize, this.currentPage);
}