import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_models.dart';
import '../../providers/chat_provider.dart';
import '../widgets/chat_room_card.dart';
import '../widgets/new_chat_dialog.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatState.rooms.isEmpty
              ? _buildEmptyState()
              : _buildChatList(chatState.rooms),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context),
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a chat with a doctor, teacher, or trainer',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _startNewChat(context),
            icon: const Icon(Icons.add),
            label: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatRoom> rooms) {
    return RefreshIndicator(
      onRefresh: () => ref.read(chatProvider.notifier).loadRooms(),
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ChatRoomCard(
            room: room,
            onTap: () => _openChatRoom(room),
          );
        },
      ),
    );
  }

  void _openChatRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(room: room),
      ),
    );
  }

  void _startNewChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewChatDialog(
        onContactSelected: (contact) async {
          Navigator.pop(context);
          final notifier = ref.read(chatProvider.notifier);
          final room = await notifier.createDirectChat(contact.id, contact.name);

          // Fallback: if creation failed, reload rooms and try to find an existing direct chat.
          if (room == null) {
            await notifier.loadRooms();
            final refreshed = ref.read(chatProvider).rooms.firstWhere(
              (r) => r.type == 'DIRECT' &&
                  r.participants.any((p) => p.id == contact.id),
              orElse: () => ChatRoom(
                id: '',
                name: contact.name,
                type: 'DIRECT',
                participants: const [],
                createdAt: DateTime.now(),
              ),
            );
            if (refreshed.id.isNotEmpty) {
              if (mounted) _openChatRoom(refreshed);
              return;
            }
          } else {
            if (mounted) _openChatRoom(room);
            return;
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not start chat. Please try again.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
