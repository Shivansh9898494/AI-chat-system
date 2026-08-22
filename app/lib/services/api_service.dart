import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Safe platform-aware base URL getter
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api'; // Android emulator alias
      }
      return 'http://127.0.0.1:8000/api'; // Windows / macOS / Desktop
    }
  }

  /// Real-time live token streaming method (`http://127.0.0.1:8000/api/chat/stream/`)
  static Stream<String> streamChatMessage({required String message}) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/chat/stream/'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'message': message});

      final response = await client.send(request);
      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          yield chunk;
        }
      } else {
        yield 'Error ${response.statusCode}: Failed to stream response.';
      }
    } catch (e) {
      final fallback = 'Hello Shivansh! Processing request for "$message". Ensure Django server is running at $baseUrl/chat/stream/.';
      final words = fallback.split(' ');
      for (var word in words) {
        yield '$word ';
        await Future.delayed(const Duration(milliseconds: 40));
      }
    } finally {
      client.close();
    }
  }

  /// Sends standard JSON chat message
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/chat/');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'reply': data['reply'] ?? 'No content returned.',
          'model': data['model'] ?? 'llama3-local:latest',
        };
      } else {
        final errData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errData['error'] ?? 'Server error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed ($e). Ensure Django backend is running at $baseUrl.',
        'details': e.toString(),
      };
    }
  }

  /// Fetch user profile info from (`/api/`)
  static Future<Map<String, dynamic>> fetchHomeInfo() async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
    } catch (_) {}
    return {'success': false};
  }
}
