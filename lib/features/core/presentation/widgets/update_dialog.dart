import 'package:flutter/material.dart';
import '../../../../core/services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateCheckResult updateInfo;
  final VoidCallback onUpdatePressed;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !updateInfo.isForceUpdate,
      child: AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1)),
        title: Text(
          'Update Available',
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version (${updateInfo.latestVersion}) is available.',
              style: const TextStyle(color: Colors.white70),
            ),
            if (updateInfo.isForceUpdate)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'This update is required to continue using the application.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          if (!updateInfo.isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('LATER', style: TextStyle(color: Colors.grey)),
            ),
          ElevatedButton(
            onPressed: onUpdatePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('UPDATE NOW'),
          ),
        ],
      ),
    );
  }
}
