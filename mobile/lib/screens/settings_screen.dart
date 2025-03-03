import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyWordNotification = true;
  bool _practiceReminder = true;
  bool _newFeaturesNotification = true;
  
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  
  final List<String> _themes = ['System', 'Light', 'Dark'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Settings
            _buildSectionHeader('Notification Preferences'),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            if (_notificationsEnabled) ...[
              CheckboxListTile(
                title: const Text('Daily Word'),
                subtitle: const Text('Get notified about the word of the day'),
                value: _dailyWordNotification,
                onChanged: (value) {
                  setState(() {
                    _dailyWordNotification = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Practice Reminder'),
                subtitle: const Text('Remind me to practice daily'),
                value: _practiceReminder,
                onChanged: (value) {
                  setState(() {
                    _practiceReminder = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('New Features'),
                subtitle: const Text('Get updates about new features'),
                value: _newFeaturesNotification,
                onChanged: (value) {
                  setState(() {
                    _newFeaturesNotification = value ?? true;
                  });
                },
              ),
            ],
            const Divider(),

            // Theme Settings
            _buildSectionHeader('Theme'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your preferred theme',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _themes.map((theme) {
                      return ChoiceChip(
                        selected: _selectedTheme == theme,
                        label: Text(theme),
                        onSelected: (selected) {
                          setState(() {
                            _selectedTheme = theme;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Language Settings
            _buildSectionHeader('Language Preferences'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your preferred language',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _languages.map((language) {
                      return ChoiceChip(
                        selected: _selectedLanguage == language,
                        label: Text(language),
                        onSelected: (selected) {
                          setState(() {
                            _selectedLanguage = language;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              subtitle: const Text('Update your profile information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to edit profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Change Email'),
              subtitle: const Text('Update your email address'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to change email screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.password_outlined),
              title: const Text('Change Password'),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to change password screen
              },
            ),
            const Divider(),

            // Privacy Settings
            _buildSectionHeader('Privacy Settings'),
            SwitchListTile(
              title: const Text('Activity Status'),
              subtitle: const Text('Show when you\'re active'),
              value: true,
              onChanged: (value) {
                // TODO: Implement activity status toggle
              },
            ),
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text('Allow others to view your profile'),
              value: false,
              onChanged: (value) {
                // TODO: Implement public profile toggle
              },
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