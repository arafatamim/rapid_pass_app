import 'package:upgrader/upgrader.dart';
import 'package:rapid_pass_info/services/upgrader.dart';

final upgrader = Upgrader(
  storeController: UpgraderStoreController(
    onLinux: () => UpgraderGitHubReleases.instance,
    onAndroid: () => UpgraderGitHubReleases.instance,
  ),
);
