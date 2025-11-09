import 'package:vibin_app/dtos/id_name.dart';

abstract interface class BaseTrack {

  abstract final int id;

  String getTitle();

  List<IdName> getArtists();

  IdName getAlbum();

  int? getTrackNumber() => null;

  int? getDuration() => null;
}