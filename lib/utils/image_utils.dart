class ImageUtils {

  static String buildUrl(int? id, ImageType type, int? quality) {
    var url = "/api/images/${id != null ? 'by-id/$id' : 'default'}?type=${type.name}";
    if (quality != null) {
      url += "&quality=$quality";
    }
    return url;
  }
}

enum ImageType {
  track,
  album,
  artist,
  playlist,
  user
}