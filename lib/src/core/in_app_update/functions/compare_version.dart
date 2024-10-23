/// Compares two version strings and returns true if the latest version is greater
/// than the current version. The comparison is done by splitting the version
/// strings into their components (separated by '.') and comparing each component
/// as an integer. The function returns true if an update is available (i.e., any
/// component of the latest version is greater than the corresponding component
/// of the current version). If all components are equal or the current version
/// is greater, the function returns false.
///
/// The version strings should be in the format 'x.y.z' where 'x', 'y' and 'z' are
/// integers.
bool compareVersion(
    {required String currentVersion, required String latestVersion}) {
  List<String> currentParts = currentVersion.split('.');
  List<String> latestParts = latestVersion.split('.');

  for (int i = 0; i < currentParts.length; i++) {
    int currentPart = int.parse(currentParts[i]);
    int latestPart = int.parse(latestParts[i]);

    if (latestPart > currentPart) {
      return true; // Update is available
    } else if (latestPart < currentPart) {
      return false; // No update
    }
  }
  return false; // Versions are the same
}
