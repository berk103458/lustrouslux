import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      bool isAvailable = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      
      if (!isAvailable) {
        // Fallback: If no biometrics, allow access (or you could deny it)
        return true; 
      }

      authenticated = await auth.authenticate(
        localizedReason: 'Scan your face or fingerprint to access The Vault.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Biometric Error: $e");
      return false;
    }
    return authenticated;
  }
}
