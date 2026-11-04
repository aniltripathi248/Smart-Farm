import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ApiClient - Low-level HTTP client for backend communication
/// 
/// Handles HTTP requests (GET, POST, DELETE) with:
/// - Automatic JSON encoding/decoding
/// - Token injection for authenticated requests
/// - Smart platform-aware Base URL resolution
/// - Automatic fallback between LAN IP and Emulator localhost
/// - Timeout handling and user-friendly error messages
class ApiClient {
  /// Constructor - sets the backend API base URL
  /// If [baseUrl] is omitted, uses the resolved [defaultBaseUrl].
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  /// Base URL of the backend API server
  final String baseUrl;

  // Stored override if changed by user or loaded from preferences
  static String? _configuredBaseUrl;

  /// Preference key for storing custom backend URL
  static const String _prefKeyBaseUrl = 'api_base_url';

  /// Primary LAN IP where the backend is hosted on this machine
  static const String _lanHostUrl = 'http://192.168.1.69:5000';

  /// Android emulator loopback alias to host machine
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000';

  /// Localhost for web and desktop
  static const String _localhostUrl = 'http://localhost:5000';

  /// Loads any previously saved base URL from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKeyBaseUrl);
      if (saved != null && saved.trim().isNotEmpty) {
        _configuredBaseUrl = saved.trim().replaceAll(RegExp(r'/+$'), '');
      }
    } catch (_) {
      // Ignore preference errors
    }
  }

  /// Sets and persists a custom Base URL
  static Future<void> setBaseUrl(String url) async {
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    _configuredBaseUrl = clean;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyBaseUrl, clean);
    } catch (_) {}
  }

  /// Returns the current active default Base URL based on environment and platform
  static String get defaultBaseUrl {
    // 1. User/runtime configured override
    if (_configuredBaseUrl != null && _configuredBaseUrl!.isNotEmpty) {
      return _configuredBaseUrl!;
    }

    // 2. Compile-time define via --dart-define=API_URL=...
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 3. Web browsers always connect to localhost:5000 locally
    if (kIsWeb) {
      return _localhostUrl;
    }

    // 4. Android: default to the host machine's LAN IP
    // (Works for physical phones on Wi-Fi and connects through emulator bridge)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _lanHostUrl;
    }

    // 5. iOS device/simulator
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _lanHostUrl;
    }

    // 6. Desktop (Windows, macOS, Linux)
    return _localhostUrl;
  }

  /// Tests connectivity to a given backend URL or the default Base URL
  static Future<bool> testConnection([String? testUrl]) async {
    final target = (testUrl ?? defaultBaseUrl).replaceAll(RegExp(r'/+$'), '');
    try {
      final uri = Uri.parse('$target/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sends a POST request to the backend API
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return _executeWithFallback(
      (url) => _sendPost(url, path, body, token: token),
    );
  }

  /// Sends a GET request to the backend API
  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
  }) async {
    return _executeWithFallback(
      (url) => _sendGet(url, path, token: token),
    );
  }

  /// Sends a DELETE request to the backend API
  Future<Map<String, dynamic>> deleteJson(
    String path, {
    String? token,
  }) async {
    return _executeWithFallback(
      (url) => _sendDelete(url, path, token: token),
    );
  }

  /// Helper to execute an HTTP operation with automatic fallback if connection fails
  Future<Map<String, dynamic>> _executeWithFallback(
    Future<Map<String, dynamic>> Function(String targetBaseUrl) action,
  ) async {
    try {
      return await action(baseUrl);
    } catch (e) {
      // If the error is not a connection/reachability issue, do not fallback
      if (!_isNetworkUnreachable(e)) {
        rethrow;
      }

      // Determine alternative fallback URL on Android
      final fallbackUrl = _getAlternativeUrl(baseUrl);
      if (fallbackUrl != null && fallbackUrl != baseUrl) {
        try {
          final result = await action(fallbackUrl);
          // If fallback succeeded, update defaultBaseUrl so subsequent calls don't fail
          _configuredBaseUrl = fallbackUrl;
          return result;
        } catch (_) {
          // If fallback also failed, rethrow the original error
        }
      }

      rethrow;
    }
  }

  String? _getAlternativeUrl(String currentUrl) {
    if (kIsWeb) {
      if (currentUrl.contains('localhost')) {
        return currentUrl.replaceFirst('localhost', '127.0.0.1');
      }
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (currentUrl.contains('192.168.1.69')) {
        return _androidEmulatorUrl;
      }
      if (currentUrl.contains('10.0.2.2')) {
        return _lanHostUrl;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      if (currentUrl.contains('localhost')) {
        return currentUrl.replaceFirst('localhost', '127.0.0.1');
      }
    }

    return null;
  }

  bool _isNetworkUnreachable(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('cannot reach') ||
        msg.contains('timed out') ||
        msg.contains('connection refused') ||
        msg.contains('failed host lookup') ||
        msg.contains('no address associated') ||
        msg.contains('network is unreachable') ||
        msg.contains('socketexception') ||
        msg.contains('clientexception');
  }

  Future<Map<String, dynamic>> _sendPost(
    String targetBase,
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$targetBase$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception(
        'Connection timed out connecting to $targetBase. Please ensure the backend is running.',
      );
    } catch (e) {
      throw _formatNetworkError(e, targetBase);
    }

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> _sendGet(
    String targetBase,
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('$targetBase$path');
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception(
        'Connection timed out connecting to $targetBase. Please ensure the backend is running.',
      );
    } catch (e) {
      throw _formatNetworkError(e, targetBase);
    }

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> _sendDelete(
    String targetBase,
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('$targetBase$path');
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception(
        'Connection timed out connecting to $targetBase. Please ensure the backend is running.',
      );
    } catch (e) {
      throw _formatNetworkError(e, targetBase);
    }

    return _processResponse(response);
  }

  Exception _formatNetworkError(dynamic e, String targetBase) {
    final errorMsg = e.toString();
    if (errorMsg.contains('host lookup') ||
        errorMsg.contains('No address associated') ||
        errorMsg.contains('Connection refused') ||
        errorMsg.contains('Failed host lookup') ||
        errorMsg.contains('SocketException') ||
        errorMsg.contains('ClientException')) {
      return Exception(
        'Cannot reach server at $targetBase. Make sure the backend API is running.',
      );
    }
    return Exception('Network error: $errorMsg');
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 503) {
      if (response.body.toLowerCase().contains('service suspended') ||
          response.body.toLowerCase().contains('suspended')) {
        throw Exception(
          'The server is currently unavailable. Please try again later or contact support.',
        );
      }
      throw Exception(
        'Service temporarily unavailable (503). Please try again in a few moments.',
      );
    }

    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is List) {
          data = {'items': decoded};
        }
      } catch (e) {
        if (e is FormatException) {
          if (response.body.trim().toLowerCase().startsWith('<!doctype html>') ||
              response.body.trim().toLowerCase().startsWith('<html')) {
            throw Exception(
              'Server returned an error page (status: ${response.statusCode}). The backend service may be down.',
            );
          }
          final preview = response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body;
          throw Exception(
            'Invalid response from server (${response.statusCode}): $preview',
          );
        }
        rethrow;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? data['message'] ?? 'Request failed');
    }
  }
}
