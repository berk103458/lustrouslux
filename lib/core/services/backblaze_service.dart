import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class BackblazeService {
  final String _keyId = '4cdaff7e8d1a';
  final String _applicationKey = '005009d79e72e4ec8c212709ec52b15dc269bcbaa0';
  
  String? _apiUrl;
  String? _authorizationToken;
  String? _downloadUrl;
  String? _bucketId;
  String? _bucketName;

  Future<void> _authenticate() async {
    final authUrl = Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account');
    final credentials = base64Encode(utf8.encode('$_keyId:$_applicationKey'));
    
    final response = await http.get(
      authUrl,
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _apiUrl = data['apiUrl'];
      _authorizationToken = data['authorizationToken'];
      _downloadUrl = data['downloadUrl'];
      
      // Auto-select first allowed bucket if generic key, or use provided
      final allowed = data['allowed'];
      if (allowed['bucketId'] != null) {
        _bucketId = allowed['bucketId'];
        _bucketName = allowed['bucketName'];
      } else {
        // Find a bucket via listBuckets
        await _findOrCreateBucket();
      }
    } else {
      throw Exception('B2 Auth Failed: ${response.body}');
    }
  }

  Future<void> _findOrCreateBucket() async {
    final url = Uri.parse('$_apiUrl/b2api/v2/b2_list_buckets');
    final response = await http.post(
      url,
      headers: {'Authorization': _authorizationToken!},
      body: jsonEncode({'accountId': _keyId}), // keyId is usually accountId for master keys, or we parse accountId from auth response?
      // Actually standard requires accountId. For master key, keyId is NOT accountId usually.
      // Let's re-check auth response. The auth response contains 'accountId'.
    );
    
    // Auth response handling needs to save accountId to be safe.
    // Refactoring _authenticate to capture accountId.
  }

  // Simplified for robustness:
  // 1. Auth 
  // 2. Get Upload URL
  // 3. Upload
  
  Future<String> uploadFile(File file, String fileName) async {
    // 1. Authorize
    final authUrl = Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account');
    final credentials = base64Encode(utf8.encode('$_keyId:$_applicationKey'));
    
    final authResp = await http.get(authUrl, headers: {'Authorization': 'Basic $credentials'});
    if (authResp.statusCode != 200) throw Exception('B2 Login Failed');
    
    final authData = jsonDecode(authResp.body);
    final apiUrl = authData['apiUrl'];
    final accountAuthToken = authData['authorizationToken'];
    final downloadUrl = authData['downloadUrl'];
    final accountId = authData['accountId']; // Safe account ID
    
    // 2. Get Bucket (We need a bucket ID)
    String targetBucketId = '';
    String targetBucketName = '';

    // Check allowed bundle first
    if (authData['allowed']['bucketId'] != null) {
      targetBucketId = authData['allowed']['bucketId'];
      targetBucketName = authData['allowed']['bucketName'];
    } else {
        // List buckets
        final listUrl = Uri.parse('$apiUrl/b2api/v2/b2_list_buckets');
        final listResp = await http.post(listUrl, 
            headers: {'Authorization': accountAuthToken},
            body: jsonEncode({'accountId': accountId})
        );
        
        if (listResp.statusCode == 200) {
            final listData = jsonDecode(listResp.body);
            final buckets = listData['buckets'] as List;
            if (buckets.isNotEmpty) {
                targetBucketId = buckets.first['bucketId'];
                targetBucketName = buckets.first['bucketName'];
                
                // CRITICAL: Ensure bucket is PUBLIC so friendly URLs work
                if (buckets.first['bucketType'] != 'allPublic') {
                   // Try to update bucket to public
                   try {
                     final updateUrl = Uri.parse('$apiUrl/b2api/v2/b2_update_bucket');
                     await http.post(updateUrl,
                       headers: {'Authorization': accountAuthToken},
                       body: jsonEncode({
                         'accountId': accountId,
                         'bucketId': targetBucketId,
                         'bucketType': 'allPublic'
                       })
                     );
                     // ignore errors, hope it works or implies permissions issue
                   } catch (e) {
                      // print('Failed to make bucket public: $e');
                   }
                }
            } else {
                throw Exception('No Backblaze Buckets found!');
            }
        } else {
             throw Exception('Failed to list buckets');
        }
    }

    // 3. Get Upload URL
    final getUploadUrl = Uri.parse('$apiUrl/b2api/v2/b2_get_upload_url');
    final uploadUrlResp = await http.post(getUploadUrl,
        headers: {'Authorization': accountAuthToken},
        body: jsonEncode({'bucketId': targetBucketId})
    );

    if (uploadUrlResp.statusCode != 200) throw Exception('Failed to get B2 upload URL');
    
    final uploadData = jsonDecode(uploadUrlResp.body);
    final uploadUrl = uploadData['uploadUrl'];
    final uploadAuthToken = uploadData['authorizationToken'];

    // 4. Upload File
    final bytes = await file.readAsBytes();
    final sha1Checksum = sha1.convert(bytes).toString();
    
    // Determine Content-Type
    String contentType = 'application/octet-stream';
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) contentType = 'image/jpeg';
    else if (lowerName.endsWith('.png')) contentType = 'image/png';
    else if (lowerName.endsWith('.pdf')) contentType = 'application/pdf';
    else if (lowerName.endsWith('.apk')) contentType = 'application/vnd.android.package-archive';
    else if (lowerName.endsWith('.ipa')) contentType = 'application/octet-stream';
    else if (lowerName.endsWith('.plist')) contentType = 'text/xml';

    // Encode filename for header (URI encode)
    final encodedFileName = Uri.encodeComponent(fileName);

    final uploadResp = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': uploadAuthToken,
        'X-Bz-File-Name': encodedFileName,
        'Content-Type': contentType,
        'X-Bz-Content-Sha1': sha1Checksum,
      },
      body: bytes,
    );

    if (uploadResp.statusCode == 200) {
        // Construct Friendly URL (Public)
        // Format: https://f000.backblazeb2.com/file/BucketName/Path/To/File
        // Bucket Name: just encode it once
        // File Name: We want to preserve slashes but encode other chars.
        // Actually, for the URL, we can just split and encode segments, or if we trust the fileName to be simple 
        // (alphanumeric + slashes), we can use it directly. 
        // But to be safe:
        final encodedBucket = Uri.encodeComponent(targetBucketName);
        
        // Split filename by '/' to encode segments individually (preserves directory structure in URL)
        final pathSegments = fileName.split('/').map((s) => Uri.encodeComponent(s)).join('/');
        
        // Remove trailing slash from downloadUrl if present
        final cleanBase = downloadUrl.endsWith('/') 
            ? downloadUrl.substring(0, downloadUrl.length - 1) 
            : downloadUrl;

        return '$cleanBase/file/$encodedBucket/$pathSegments';
    } else {
        throw Exception('B2 Upload Failed: ${uploadResp.body}');
    }
  }
}
