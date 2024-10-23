import 'package:package_info_plus/package_info_plus.dart';

Future<List<String>> getAppVersionAndBuildNumber() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return [packageInfo.version, packageInfo.buildNumber];
}
