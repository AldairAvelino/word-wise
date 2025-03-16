import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _settings = {
    'notifications': true,
    'dailyWord': true,
    'practiceRemider': true,
    'featuresUpdate': true,
    'theme': 'system',
    'language': 'en',
    'activityStatus': true,
    'publicProfile': true,
  };

  final Map<String, String> _languageMap = {
    'en': 'English',
    'pt': 'Portuguese',
    'sp': 'Spanish',
    'fr': 'French',
    'gr': 'German',
    'ch': 'Chinese',
  };

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) return;

    try {
      final response = await http.get(
        Uri.parse('https://word-wise-16vw.onrender.com/api/user/settings'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _settings = data['settings'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSettings(String key, dynamic value) async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) return;

    try {
      setState(() => _settings[key] = value);

      final response = await http.put(
        Uri.parse('https://word-wise-16vw.onrender.com/api/user/settings'),
        headers: {
          'Authorization': 'Bearer ${authState.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'settings': _settings,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update settings');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Notification Preferences'),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _settings['notifications'],
              onChanged: (value) => _updateSettings('notifications', value),
            ),
            if (_settings['notifications']) ...[
              CheckboxListTile(
                title: const Text('Daily Word'),
                subtitle: const Text('Get notified about the word of the day'),
                value: _settings['dailyWord'],
                onChanged: (value) => _updateSettings('dailyWord', value),
              ),
              CheckboxListTile(
                title: const Text('Practice Reminder'),
                subtitle: const Text('Remind me to practice daily'),
                value: _settings['practiceRemider'],
                onChanged: (value) => _updateSettings('practiceRemider', value),
              ),
              CheckboxListTile(
                title: const Text('New Features'),
                subtitle: const Text('Get updates about new features'),
                value: _settings['featuresUpdate'],
                onChanged: (value) => _updateSettings('featuresUpdate', value),
              ),
            ],
            const Divider(),

            _buildSectionHeader('Theme'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select your preferred theme'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['system', 'light', 'dark'].map((theme) {
                      return ChoiceChip(
                        selected: _settings['theme'] == theme,
                        label: Text(theme[0].toUpperCase() + theme.substring(1)),
                        onSelected: (selected) {
                          if (selected) _updateSettings('theme', theme);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),

            _buildSectionHeader('Language Preferences'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select your preferred language'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _languageMap.entries.map((entry) {
                      return ChoiceChip(
                        selected: _settings['language'] == entry.key,
                        label: Text(entry.value),
                        onSelected: (selected) {
                          if (selected) _updateSettings('language', entry.key);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),

            _buildSectionHeader('Privacy Settings'),
            SwitchListTile(
              title: const Text('Activity Status'),
              subtitle: const Text('Show when you\'re active'),
              value: _settings['activityStatus'],
              onChanged: (value) => _updateSettings('activityStatus', value),
            ),
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text('Allow others to view your profile'),
              value: _settings['publicProfile'],
              onChanged: (value) => _updateSettings('publicProfile', value),
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Data & Privacy'),
              subtitle: const Text('Manage your data and privacy settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to data & privacy screen
              },
            ),
            const Divider(),

            // Danger Zone
            _buildSectionHeader('Danger Zone', color: Colors.red),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Permanently delete your account and data'),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}