/// A provisioning profile installed for one signed bundle.
final class InstalledProfile {
  /// Creates installed-profile metadata.
  const InstalledProfile({
    required this.bundleId,
    required this.uuid,
    required this.name,
    required this.teamId,
    required this.installedPath,
  });

  /// Bundle identifier authorized by the profile.
  final String bundleId;

  /// Provisioning-profile UUID.
  final String uuid;

  /// Provisioning-profile name.
  final String name;

  /// Apple developer team identifier.
  final String teamId;

  /// Temporary installed profile path.
  final String installedPath;
}
