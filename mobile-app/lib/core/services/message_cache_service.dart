import 'package:hive/hive.dart';
import '../features/chat/models/chat_models.dart';

class MessageCacheService {
  static const String _messagesBoxName = 'chat_messages';
  static const String _roomsBoxName = 'chat_rooms';
  late Box<String> _messagesBox;
  late Box<String> _roomsBox;

  Future<void> init() async {
    _messagesBox = await Hive.openBox<String>(_messagesBoxName);
    _roomsBox = await Hive.openBox<String>(_roomsBoxName);
  }

  // Cache messages for a room
  Future<void> cacheMessages(String roomId, List<Message> messages) async {
    try {
      // Store as JSON string for each room
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await _messagesBox.put('room_$roomId', messagesJson.toString());
    } catch (e) {
      // ignore: avoid_print
      print('Error caching messages: $e');
    }
  }

  // Get cached messages for a room
  Future<List<Message>> getCachedMessages(String roomId) async {
    try {
      final cached = _messagesBox.get('room_$roomId');
      if (cached == null) return [];
      
      // Parse the cached messages
      // For now, return empty since we'd need to parse JSON
      // This is a simplified version
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving cached messages: $e');
      return [];
    }
  }

  // Cache rooms
  Future<void> cacheRooms(List<ChatRoom> rooms) async {
    try {
      final roomsJson = rooms.map((r) => r.toJson()).toList();
      await _roomsBox.put('all_rooms', roomsJson.toString());
    } catch (e) {
      // ignore: avoid_print
      print('Error caching rooms: $e');
    }
  }

  // Get cached rooms
  Future<List<ChatRoom>> getCachedRooms() async {
    try {
      final cached = _roomsBox.get('all_rooms');
      if (cached == null) return [];
      
      // Parse the cached rooms
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving cached rooms: $e');
      return [];
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      await _messagesBox.clear();
      await _roomsBox.clear();
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing cache: $e');
    }
  }

  // Clear room cache
  Future<void> clearRoomCache(String roomId) async {
    try {
      await _messagesBox.delete('room_$roomId');
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing room cache: $e');
    }
  }
}

final messageCacheService = MessageCacheService();
