import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/backblaze_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';

class AdminReleasePage extends StatefulWidget {
  const AdminReleasePage({super.key});

  @override
  State<AdminReleasePage> createState() => _AdminReleasePageState();
}

class _AdminReleasePageState extends State<AdminReleasePage> {
  final TextEditingController _versionController = TextEditingController();
  final BackblazeService _backblazeService = sl<BackblazeService>();

  PlatformFile? _apkFile;
  PlatformFile? _ipaFile;

  bool _isUploading = false;
  String _statusMessage = "";
  double _progress = 0.0;

  Future<void> _pickApk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null) {
      setState(() => _apkFile = result.files.first);
    }
  }

  Future<void> _pickIpa() async {
    // 'ipa' extension might be restricted on Android picker, use 'any' and filter manually or trust user
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, 
    );
    if (result != null) {
      if(result.files.first.name.contains('.ipa')) {
        setState(() => _ipaFile = result.files.first);
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen .ipa dosyası seçin!")));
      }
    }
  }

  Future<void> _startUpload() async {
    if (_versionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen versiyon girin (örn: 1.2.0)")));
      return;
    }
    if (_apkFile == null && _ipaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("En az bir dosya seçmelisiniz.")));
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = "İşlem Başlıyor...";
    });

    try {
      final version = _versionController.text.trim();
      final updates = <String, dynamic>{
        'latest_version': version,
      };

      // 1. Upload APK
      if (_apkFile != null) {
        setState(() => _statusMessage = "APK Yükleniyor...");
        final file = File(_apkFile!.path!);
        final url = await _backblazeService.uploadFile(file, 'releases/android/LustrousLux_v$version.apk');
        updates['download_url'] = url;
      }

      // 2. Upload IPA & Generate Plist
      if (_ipaFile != null) {
        setState(() => _statusMessage = "IPA Yükleniyor...");
        final file = File(_ipaFile!.path!);
        final ipaUrl = await _backblazeService.uploadFile(file, 'releases/ios/LustrousLux_v$version.ipa');
        
        setState(() => _statusMessage = "Manifest Oluşturuluyor...");
        final plistContent = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>$ipaUrl</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>display-image</string>
                    <key>url</key>
                    <string>https://lustrouslux.web.app/assets/images/logo.png</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>full-size-image</string>
                    <key>url</key>
                    <string>https://lustrouslux.web.app/assets/images/logo.png</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>com.example.lustrousLux</string>
                <key>bundle-version</key>
                <string>$version</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>LustrousLux</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>""";

        // Write Plist to temp file upload
        final tempDir = Directory.systemTemp;
        final plistFile = File('${tempDir.path}/manifest_v$version.plist');
        await plistFile.writeAsString(plistContent);
        
        setState(() => _statusMessage = "Manifest Yükleniyor...");
        final plistUrl = await _backblazeService.uploadFile(plistFile, 'releases/ios/manifest_v$version.plist');
        
        updates['ios_ipa_url'] = ipaUrl; // Save direct link for non-OTA download
        updates['ios_ipa_url'] = ipaUrl; // Save direct link for non-OTA download
        updates['ios_plist_url'] = plistUrl;
        updates['ios_install_link'] = "itms-services://?action=download-manifest&url=${Uri.encodeComponent(plistUrl)}";
      }

      // 3. Update Database
      setState(() => _statusMessage = "Veritabanı Güncelleniyor...");
      await FirebaseFirestore.instance.collection('app_config').doc('maintenance').set(updates, SetOptions(merge: true));

      setState(() {
        _isUploading = false;
        _statusMessage = "BAŞARILI! ✅";
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.black,
            title: const Text("Yükleme Tamamlandı", style: TextStyle(color: LustrousTheme.lustrousGold)),
            content: Text("Sürüm $version başarıyla yayınlandı.", style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("TAMAM"))
            ],
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusMessage = "HATA: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text("YENİ SÜRÜM YAYINLA"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isUploading) ...[
               const CircularProgressIndicator(color: LustrousTheme.lustrousGold),
               const SizedBox(height: 20),
               Text(_statusMessage, style: const TextStyle(color: LustrousTheme.lustrousGold, fontSize: 18)),
               const SizedBox(height: 40),
            ],

            // Version Input
            TextField(
              controller: _versionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Versiyon Numarası (örn: 1.2.0)",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: LustrousTheme.lustrousGold)),
              ),
            ),
            const SizedBox(height: 30),

            // APK Picker
            _buildFileCard(
              title: "ANDROID APK",
              icon: Icons.android,
              file: _apkFile,
              color: Colors.lightGreenAccent,
              onTap: _pickApk,
            ),
            const SizedBox(height: 20),

            // IPA Picker
            _buildFileCard(
              title: "iOS IPA",
              icon: Icons.apple,
              file: _ipaFile,
              color: Colors.white,
              onTap: _pickIpa,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _startUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LustrousTheme.lustrousGold,
                  foregroundColor: Colors.black,
                ),
                child: const Text("YAYINLA (DEPLOY)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
             const SizedBox(height: 20),
             Text(_statusMessage, style: TextStyle(color: _statusMessage.contains("HATA") ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard({
    required String title,
    required IconData icon,
    required PlatformFile? file,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isUploading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(icon, color: color, size: 32),
              title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              subtitle: Text(file?.name ?? "Dosya Seçilmedi", style: const TextStyle(color: Colors.grey)),
              trailing: ElevatedButton(
                onPressed: _isUploading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: color.withOpacity(0.5)),
                  foregroundColor: color,
                ),
                child: const Text("SEÇ"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
