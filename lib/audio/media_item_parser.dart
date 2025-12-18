import 'package:audio_service/audio_service.dart';

extension MediaItemParser on MediaItem {

  int? get trackId {
    final idPart = id.split('-').firstOrNull;

    if (idPart == null) return null;

    final idInt = int.tryParse(idPart);
    return idInt;
  }
}