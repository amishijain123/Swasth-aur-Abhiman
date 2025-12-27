import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../repositories/admin_repository.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedBlock;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final users = adminState.usersList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (block) {
              setState(() => _selectedBlock = block == 'All' ? null : block);
              ref.read(adminProvider.notifier).loadUsers(block: _selectedBlock);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'All', child: Text('All Blocks')),
              const PopupMenuItem(value: 'VIKASNAGAR', child: Text('Vikasnagar')),
              const PopupMenuItem(value: 'DOIWALA', child: Text('Doiwala')),
              const PopupMenuItem(value: 'SAHASPUR', child: Text('Sahaspur')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Users'),
            Tab(text: 'Doctors'),
            Tab(text: 'Teachers'),
            Tab(text: 'Trainers'),
          ],
          onTap: (index) {
            final roles = [null, 'USER', 'DOCTOR', 'TEACHER', 'TRAINER'];
            ref.read(adminProvider.notifier).loadUsers(
                  role: roles[index],
                  block: _selectedBlock,
                );
          },
        ),
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? _buildEmptyState()
              : _buildUsersList(users),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<AdminUser> users) {
    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).loadUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(
            user: user,
            onTap: () => _showUserDetails(user),
          );
        },
      ),
    );
  }

  void _showUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _getRoleColor(user.role),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.email, 'Email', user.email),
            _buildDetailRow(Icons.phone, 'Phone', user.phone),
            if (user.block != null)
              _buildDetailRow(Icons.apartment, 'Block', user.block!),
            _buildDetailRow(
              Icons.calendar_today,
              'Joined',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement role change
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Change Role'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement deactivate
                    },
                    icon: const Icon(Icons.block),
                    label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
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
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  fontSize: 10,
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user.block != null) ...[
              const SizedBox(width: 8),
              Text(
                user.block!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: user.isActive
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.cancel, color: Colors.red, size: 20),
      ),
    );
  }

  Color _getRoleColor(String role) {
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
}
