import 'package:flutter/foundation.dart';
import 'package:rapid_pass_info/meta.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
import 'dart:convert';

class UpgraderGitHubReleases extends UpgraderStore {
  UpgraderGitHubReleases._();

  static final UpgraderGitHubReleases instance = UpgraderGitHubReleases._();

  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    final githubReleaseUrl = meta["githubReleaseUrl"];

    if (githubReleaseUrl == null) {
      if (kDebugMode) {
        debugPrint(
            "upgrader: UpgraderGitHubReleases.getVersionInfo: githubReleaseUrl is null");
      }
      throw Exception("githubReleaseUrl is null");
    }

    final res = await state.client.get(Uri.parse(githubReleaseUrl));
    if (res.statusCode == 404) {
      if (kDebugMode) {
        debugPrint(
            "upgrader: UpgraderGitHubReleases.getVersionInfo: latest release not found");
      }
      throw Exception("latest release not found");
    }

    final json = jsonDecode(res.body);
    final releaseUrl = json["html_url"] as String;
    final tagName = json["tag_name"] as String;
    final body = json["body"] as String;

    final version = Version.parse(tagName.replaceFirst("v", ""));

    UpgraderVersionInfo versionInfo = UpgraderVersionInfo(
      installedVersion: installedVersion,
      appStoreListingURL: releaseUrl,
      appStoreVersion: version,
      releaseNotes: body,
    );

    return versionInfo;
  }
}
