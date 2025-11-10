enum MetadataImageSize {
  small(128),
  medium(256),
  large(512);

  final int pixelSize;

  const MetadataImageSize(
    this.pixelSize,
  );
}