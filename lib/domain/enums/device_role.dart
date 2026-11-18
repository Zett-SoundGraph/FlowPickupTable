enum DeviceRole {
  leader,
  follower,
  unknown,
  none;

  /// Parses the backend's spelling; anything unparsable is [none].
  static DeviceRole fromValue(String? value) {
    for (final DeviceRole role in values) {
      if (role.name == value) {
        return role;
      }
    }
    return none;
  }
}
