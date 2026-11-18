enum VideoPlayerLib {
  mediakit,
  videoplayer;

  /// Parses the backend's spelling; anything unparsable is [videoplayer].
  static VideoPlayerLib fromValue(String? value) {
    for (final VideoPlayerLib lib in values) {
      if (lib.name == value) {
        return lib;
      }
    }
    return videoplayer;
  }
}
