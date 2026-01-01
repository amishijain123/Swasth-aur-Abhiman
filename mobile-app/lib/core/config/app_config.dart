import 'package:flutter/foundation.dart';

class AppConfig {
  // Set this to true to use mock/offline mode without backend
  static const bool useMockBackend = kIsWeb; // Use mock on web since backend isn't available
  
  // Backend configuration
  static const String backendUrl = 'http://localhost:3000/api';
}
