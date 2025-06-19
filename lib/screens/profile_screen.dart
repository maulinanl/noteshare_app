import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildCoinsSection(),
          const SizedBox(height: 24),
          _buildMyNotesSection(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Text(
            _userModel?.displayName.isNotEmpty == true
                ? _userModel!.displayName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
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
                _userModel?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _userModel?.email ?? '',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              if (_userModel?.bio.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  _userModel!.bio,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Notes', '12', Icons.article),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Followers', '48', Icons.people),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Following', '23', Icons.person_add),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_userModel?.coins ?? 0} Coins',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Use coins to unlock premium content',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showBuyCoinsDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy More'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('authorId', isEqualTo: _authService.currentUser?.uid)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notes = snapshot.data!.docs;

            if (notes.isEmpty) {
              return const Text('No notes yet. Start writing!');
            }

            return Column(
              children: notes.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(
                    data['content'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text('${data['views'] ?? 0} views'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Implement edit profile
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Implement notifications settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: Implement privacy settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: _signOut,
        ),
      ],
    );
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(doc);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBuyCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buy Coins'),
        content: const Text('Coin purchasing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }
}
