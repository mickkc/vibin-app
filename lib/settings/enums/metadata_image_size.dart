enum MetadataImageSize {
  small("small"),
  large("large"),
  original("original");

  final String qualityParam;

  const MetadataImageSize(
    this.qualityParam,
  );
}