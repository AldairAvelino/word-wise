import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'package:mobile/screens/auth/get_started_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/help_support_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) return;

    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/user/statistics'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userStats = data;
        });
      } else {
        throw Exception('Failed to fetch user statistics');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching statistics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Words\nLearned',
            _userStats?['totalSavedWords']?.toString() ?? '0',
          ),
          _buildDivider(),
          _buildStatItem(
            'Mastered\nWords',
            _userStats?['masteredWords']?.toString() ?? '0',
          ),
          _buildDivider(),
          _buildStatItem(
            'Liked\nWords',
            _userStats?['likedWords']?.toString() ?? '0',
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserData() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/auth/me'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['user'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Sign in to view your profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create an account or sign in to track your progress and save your favorite words',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GetStartedScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userData == null
                ? _buildUnauthenticatedView()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userData!['user_metadata']['username'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userData!['email'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Joined ${DateTime.parse(_userData!['created_at']).toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildStatsCard(),
                              const SizedBox(height: 20),
                              _buildMenuSection(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
  Widget _buildMenuSection(BuildContext context) {  // Accept context parameter
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences, notifications',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.bar_chart,
          title: 'Progress',
          subtitle: 'View learning statistics',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'View your badges and rewards',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs, contact support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            );
          },
        ),
      ],
    );
  }
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        // Add avatar selection functionality here
        const SizedBox(height: 20),
      ],
    );
  }
}