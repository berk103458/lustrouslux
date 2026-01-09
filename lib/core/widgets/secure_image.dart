import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SecureImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SecureImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Proxy Strategy: Use wsrv.nl to bypass device-level blocks on Backblaze/Firestore domains.
    // Encodes the target URL so the proxy fetches it server-side.
    final proxyUrl = 'https://wsrv.nl/?url=${Uri.encodeComponent(imageUrl)}&output=webp';

    return CachedNetworkImage(
      imageUrl: proxyUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) {
        // Fallback: If proxy fails, try original URL (unlikely to work if blocked, but good practice)
        // Or show a clear error icon.
        return Container(
          width: width,
          height: height,
          color: Colors.grey[900],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey),
              SizedBox(height: 4),
              Text("Img Error", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}
