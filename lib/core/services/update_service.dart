import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _kIgnoredVersionKey = 'ignored_update_version';

  Future<UpdateCheckResult> checkForUpdate() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Get remote config from Firestore
      final doc = await _firestore.collection('app_config').doc('maintenance').get();
      
      if (!doc.exists) return UpdateCheckResult(hasUpdate: false);

      final data = doc.data()!;
      final String latestVersion = data['latest_version'] ?? currentVersion;
      final String updateUrl = data['update_url'] ?? '';
      final bool forceUpdate = data['force_update'] ?? false;

      // 3. Check Persistence (If user ignored this version before)
      if (!forceUpdate) {
        final prefs = await SharedPreferences.getInstance();
        final ignoredVersion = prefs.getString(_kIgnoredVersionKey);
        if (ignoredVersion == latestVersion) {
            // User already saw and ignored this version.
            return UpdateCheckResult(hasUpdate: false);
        }
      }

      // 4. Compare versions
      final hasUpdate = _isVersionGreaterThan(latestVersion, currentVersion);

      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        isForceUpdate: forceUpdate,
        updateUrl: updateUrl,
        latestVersion: latestVersion,
      );
    } catch (e) {
      return UpdateCheckResult(hasUpdate: false);
    }
  }

  // If user dismisses the dialog (and it's not forced), call this.
  Future<void> ignoreUpdate(String version) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kIgnoredVersionKey, version);
  }

  bool _isVersionGreaterThan(String newVersion, String currentVersion) {
    List<int> newParts = newVersion.split('.').map(int.parse).toList();
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < newParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class UpdateCheckResult {
  final bool hasUpdate;
  final bool isForceUpdate;
  final String updateUrl;
  final String latestVersion;

  UpdateCheckResult({
    this.hasUpdate = false,
    this.isForceUpdate = false,
    this.updateUrl = '',
    this.latestVersion = '',
  });
}
