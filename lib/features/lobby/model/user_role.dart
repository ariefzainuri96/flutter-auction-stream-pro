enum UserRole {
  viewer,
  host;

  String get displayName {
    switch (this) {
      case UserRole.viewer:
        return 'Viewer';
      case UserRole.host:
        return 'Host';
    }
  }

  String get iconName {
    switch (this) {
      case UserRole.viewer:
        return 'visibility';
      case UserRole.host:
        return 'podium';
    }
  }
}
