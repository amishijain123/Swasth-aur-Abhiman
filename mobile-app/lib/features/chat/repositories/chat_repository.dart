import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/services/api_service.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  // Get all chat rooms for current user
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _apiService.get('/chat/rooms');
      return (response.data as List)
          .map((r) => ChatRoom.fromJson(r))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get messages for a room
  Future<List<Message>> getMessages(String roomId, {int page = 1}) async {
    try {
      final response = await _apiService.get(
        '/chat/rooms/$roomId/messages',
        queryParameters: {'page': page.toString()},
      );
      return (response.data as List)
          .map((m) => Message.fromJson(m))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Send a text message
  Future<Message?> sendMessage(String roomId, String content, {String type = 'TEXT'}) async {
    try {
      final response = await _apiService.post(
        '/chat/rooms/$roomId/messages',
        data: {
          'content': content,
          'type': type,
        },
      );
      return Message.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Send an audio message
  Future<Message?> sendAudioMessage(
    String roomId, 
    String filePath, 
    int duration,
  ) async {
    try {
      final formData = FormData.fromMap({
        'type': 'AUDIO',
        'content': 'Voice message',
        'audioDuration': duration,
        'audio': await MultipartFile.fromFile(filePath, filename: 'voice_message.m4a'),
      });
      
      final response = await _apiService.post(
        '/chat/rooms/$roomId/messages',
        data: formData,
      );
      return Message.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Create a new chat room (direct or group)
  Future<ChatRoom?> createRoom({
    required String name,
    required List<String> participantIds,
    String type = 'DIRECT',
  }) async {
    try {
      final response = await _apiService.post(
        '/chat/rooms',
        data: {
          'name': name,
          'type': type,
          'participantIds': participantIds,
        },
      );
      return ChatRoom.fromJson(response.data);
    } catch (e) {
      // Log to console so we can see why chat creation failed (e.g., 401, 422).
      // In production you might want to route this to a logger instead of debugPrint.
      // ignore: avoid_print
      print('createRoom error: $e');
      return null;
    }
  }

  // Get available contacts (doctors, teachers, trainers, users)
  Future<List<AvailableContact>> getAvailableContacts({String? role}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;

      final response = await _apiService.get(
        '/chat/contacts',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((c) => AvailableContact.fromJson(c))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String roomId) async {
    try {
      await _apiService.patch('/chat/rooms/$roomId/read');
    } catch (e) {
      // Ignore errors
    }
  }

  // Upload media file (image, document, etc.)
  Future<Map<String, dynamic>?> uploadMedia({
    required String filePath,
    required String fileName,
    required String mediaType, // 'image', 'document', 'audio', 'video'
    int? duration,
  }) async {
    try {
      // On web, use a simple approach without MultipartFile
      if (kIsWeb) {
        // For web, return a mock URL since we can't access file system
        // The mock interceptor will handle the actual upload request
        return {
          'url': '/uploads/chat/web-${DateTime.now().millisecondsSinceEpoch}',
          'originalName': fileName,
          'size': 0,
          'mimeType': 'application/octet-stream',
          'type': mediaType,
          'duration': duration,
        };
      }

      // On native platforms, use MultipartFile
      final formData = FormData.fromMap({
        'type': mediaType,
        if (duration != null) 'duration': duration,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      // ignore: avoid_print
      print('Uploading $mediaType to /chat/upload: $fileName');
      
      final response = await _apiService.post(
        '/chat/upload',
        data: formData,
      );
      
      // ignore: avoid_print
      print('Upload success: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('uploadMedia error: $e');
      rethrow; // Re-throw so caller can handle
    }
  }

  // Send a message with media attachment
  Future<Message?> sendMediaMessage({
    required String roomId,
    required String mediaUrl,
    required String mediaType,
    String? content,
    int? duration,
  }) async {
    try {
      final response = await _apiService.post(
        '/chat/rooms/$roomId/messages',
        data: {
          'content': content ?? '$mediaType message',
          'type': mediaType.toUpperCase(),
          'mediaUrl': mediaUrl,
          if (duration != null) 'audioDuration': duration,
        },
      );
      return Message.fromJson(response.data);
    } catch (e) {
      // ignore: avoid_print
      print('sendMediaMessage error: $e');
      return null;
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatRepository(apiService);
});
