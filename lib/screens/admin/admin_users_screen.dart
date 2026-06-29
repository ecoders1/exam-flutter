import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.usersTable
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _users = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    return _users.where((u) {
      final name = (u['full_name'] as String? ?? '').toLowerCase();
      final email = (u['email'] as String? ?? '').toLowerCase();
      return name.contains(_search.toLowerCase()) ||
          email.contains(_search.toLowerCase());
    }).toList();
  }

  Future<void> _toggleBlock(Map<String, dynamic> user) async {
    final isBlocked = user['is_blocked'] as bool? ?? false;
    try {
      await SupabaseService.usersTable
          .update({'is_blocked': !isBlocked})
          .eq('id', user['id']);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBlocked ? 'User unblocked' : 'User blocked'),
            backgroundColor:
                isBlocked ? AppTheme.correctGreen : AppTheme.wrongRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users (${_users.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('No users found',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final u = _filtered[i];
                        return _UserTile(
                          user: u,
                          onBlock: () => _toggleBlock(u),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: i * 40));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBlock;

  const _UserTile({required this.user, required this.onBlock});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final isAdmin = user['is_admin'] as bool? ?? false;
    final isBlocked = user['is_blocked'] as bool? ?? false;
    final unlocked =
        (user['unlocked_departments'] as List?)?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? AppTheme.wrongRed.withOpacity(0.3)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isAdmin
                ? AppTheme.gold.withOpacity(0.2)
                : AppTheme.primary.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: isAdmin ? AppTheme.gold : AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('ADMIN',
                            style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.wrongRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('BLOCKED',
                            style: TextStyle(
                                color: AppTheme.wrongRed,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                Text(email,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '$unlocked dept${unlocked != 1 ? 's' : ''} unlocked',
                  style:
                      const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isBlocked ? Icons.lock_open : Icons.block,
              color: isBlocked ? AppTheme.correctGreen : AppTheme.wrongRed,
              size: 20,
            ),
            onPressed: isAdmin ? null : onBlock,
            tooltip: isBlocked ? 'Unblock user' : 'Block user',
          ),
        ],
      ),
    );
  }
}
