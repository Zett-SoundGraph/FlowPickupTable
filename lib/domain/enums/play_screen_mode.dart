/// The display mode of the Viewer Play screen.
enum PlayScreenMode {
  idle,
  presentation;

  /// Parses the backend's spelling; anything unparsable is [idle].
  static PlayScreenMode fromValue(String? value) {
    for (final PlayScreenMode mode in values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return idle;
  }
}
