import 'package:flutter/material.dart';
import '../../models/chat_models.dart';
import 'package:intl/intl.dart';

class ChatRoomCard extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const ChatRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participant = room.participants.isNotEmpty
        ? room.participants.first
        : null;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(participant?.role),
            child: Text(
              room.name.isNotEmpty ? room.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (participant?.isOnline ?? false)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.name,
              style: TextStyle(
                fontWeight:
                    room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.lastMessage != null)
            Text(
              _formatTime(room.lastMessage!.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: room.unreadCount > 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          if (participant != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(participant.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                participant.roleDisplay,
                style: TextStyle(
                  fontSize: 10,
                  color: _getRoleColor(participant.role),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Text(
              room.lastMessage?.content ?? 'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight:
                    room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                room.unreadCount > 99 ? '99+' : room.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'DOCTOR':
        return Colors.green;
      case 'TEACHER':
        return Colors.blue;
      case 'TRAINER':
        return Colors.orange;
      case 'ADMIN':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
