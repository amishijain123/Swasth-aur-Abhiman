import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class ChatState {
  final List<ChatRoom> rooms;
  final Map<String, List<Message>> messages;
  final List<AvailableContact> contacts;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String? activeRoomId;

  const ChatState({
    this.rooms = const [],
    this.messages = const {},
    this.contacts = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.activeRoomId,
  });

  ChatState copyWith({
    List<ChatRoom>? rooms,
    Map<String, List<Message>>? messages,
    List<AvailableContact>? contacts,
    bool? isLoading,
    bool? isSending,
    String? error,
    String? activeRoomId,
  }) {
    return ChatState(
      rooms: rooms ?? this.rooms,
      messages: messages ?? this.messages,
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      activeRoomId: activeRoomId ?? this.activeRoomId,
    );
  }

  List<Message> getMessagesForRoom(String roomId) {
    return messages[roomId] ?? [];
  }

  int get totalUnreadCount {
    return rooms.fold(0, (sum, room) => sum + room.unreadCount);
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(const ChatState());

  Future<void> loadRooms() async {
    state = state.copyWith(isLoading: true);

    try {
      final rooms = await _repository.getChatRooms();
      rooms.sort((a, b) {
        final aTime = a.lastMessage?.createdAt ?? a.createdAt;
        final bTime = b.lastMessage?.createdAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMessages(String roomId) async {
    state = state.copyWith(
      isLoading: true,
      activeRoomId: roomId,
    );

    try {
      final messages = await _repository.getMessages(roomId);
      await _repository.markAsRead(roomId);

      final updatedMessages = Map<String, List<Message>>.from(state.messages);
      updatedMessages[roomId] = messages;

      // Update unread count for this room
      final updatedRooms = state.rooms.map((room) {
        if (room.id == roomId) {
          return ChatRoom(
            id: room.id,
            name: room.name,
            description: room.description,
            type: room.type,
            participants: room.participants,
            lastMessage: room.lastMessage,
            unreadCount: 0,
            createdAt: room.createdAt,
            updatedAt: room.updatedAt,
          );
        }
        return room;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        rooms: updatedRooms,
        isLoading: false,
      );
    } catch (e) {
      // On error, try to load cached messages
      // ignore: avoid_print
      print('Error loading messages, trying cache: $e');
      
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages (offline mode)',
      );
    }
  }

  Future<bool> sendMessage(String roomId, String content) async {
    state = state.copyWith(isSending: true);

    try {
      final message = await _repository.sendMessage(roomId, content);

      if (message != null) {
        final updatedMessages = Map<String, List<Message>>.from(state.messages);
        updatedMessages[roomId] = [message, ...(updatedMessages[roomId] ?? [])];

        state = state.copyWith(
          messages: updatedMessages,
          isSending: false,
        );
        return true;
      }

      state = state.copyWith(isSending: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> sendAudioMessage(String roomId, String filePath, int duration) async {
    state = state.copyWith(isSending: true);

    try {
      final message = await _repository.sendAudioMessage(roomId, filePath, duration);

      if (message != null) {
        final updatedMessages = Map<String, List<Message>>.from(state.messages);
        updatedMessages[roomId] = [message, ...(updatedMessages[roomId] ?? [])];

        state = state.copyWith(
          messages: updatedMessages,
          isSending: false,
        );
        return true;
      }

      state = state.copyWith(isSending: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> sendMediaMessage(
    String roomId,
    String filePath,
    String mediaType, {
    String? caption,
  }) async {
    state = state.copyWith(isSending: true);

    try {
      // First upload the media file
      final uploadResult = await _repository.uploadMedia(
        filePath: filePath,
        fileName: filePath.split('/').last,
        mediaType: mediaType,
      );

      if (uploadResult == null) {
        state = state.copyWith(
          isSending: false,
          error: 'Failed to upload $mediaType. Please check your connection and try again.',
        );
        return false;
      }

      // Then send the message with the media URL and optional caption
      final message = await _repository.sendMediaMessage(
        roomId: roomId,
        mediaUrl: uploadResult['url'] as String,
        mediaType: mediaType,
        content: caption ?? '${mediaType.capitalize()} message',
      );

      if (message != null) {
        final updatedMessages = Map<String, List<Message>>.from(state.messages);
        updatedMessages[roomId] = [message, ...(updatedMessages[roomId] ?? [])];

        state = state.copyWith(
          messages: updatedMessages,
          isSending: false,
        );
        return true;
      }

      state = state.copyWith(
        isSending: false,
        error: 'Failed to send message. Please try again.',
      );
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('sendMediaMessage error: $e');
      state = state.copyWith(
        isSending: false,
        error: 'Error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> loadContacts({String? role}) async {
    try {
      final contacts = await _repository.getAvailableContacts(role: role);
      state = state.copyWith(contacts: contacts);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<ChatRoom?> createDirectChat(String userId, String userName) async {
    try {
      // Try creating (or retrieving) a direct chat with the selected contact.
      final createdRoom = await _repository.createRoom(
        name: userName,
        participantIds: [userId],
        type: 'DIRECT',
      );

      if (createdRoom != null) {
        // Merge or prepend the room into state so it appears instantly.
        final exists = state.rooms.any((r) => r.id == createdRoom.id);
        final updatedRooms = exists
            ? state.rooms
                .map((r) => r.id == createdRoom.id ? createdRoom : r)
                .toList()
            : [createdRoom, ...state.rooms];

        state = state.copyWith(rooms: updatedRooms);
        // Also refresh rooms from backend so unread counts/lastMessage stay correct.
        await loadRooms();
        return createdRoom;
      }

      // Fallback: reload rooms and find an existing direct chat with this contact.
      await loadRooms();
      final existingRoom = state.rooms.firstWhere(
        (room) => room.type == 'DIRECT' && room.participants.any((p) => p.id == userId),
        orElse: () => ChatRoom(
          id: '',
          name: '',
          type: 'DIRECT',
          participants: const [],
          createdAt: DateTime.now(),
        ),
      );

      if (existingRoom.id.isNotEmpty) {
        return existingRoom;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // WebSocket message handling
  void onNewMessage(Message message) {
    final updatedMessages = Map<String, List<Message>>.from(state.messages);
    updatedMessages[message.roomId] = [
      message,
      ...(updatedMessages[message.roomId] ?? [])
    ];

    // Update room's last message
    final updatedRooms = state.rooms.map((room) {
      if (room.id == message.roomId) {
        return ChatRoom(
          id: room.id,
          name: room.name,
          description: room.description,
          type: room.type,
          participants: room.participants,
          lastMessage: message,
          unreadCount: state.activeRoomId == message.roomId
              ? 0
              : room.unreadCount + 1,
          createdAt: room.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return room;
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      rooms: updatedRooms,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});
