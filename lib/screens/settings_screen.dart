// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state variables
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  bool autoMarkNearby = false;
  double soundVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          _buildSection(
            l10n.profile,
            [
              _buildProfileTile(context),
            ],
          ),

          const SizedBox(height: 20),

          // App Preferences
          _buildSection(
            l10n.preferences,
            [
              _buildLanguageTile(context, l10n, localeProvider),
              _buildNotificationTile(context, l10n),
            ],
          ),

          const SizedBox(height: 20),

          // Collection Settings
          _buildSection(
            l10n.collections,
            [
              _buildLocationTile(context, l10n),
              _buildAutoMarkTile(context, l10n),
              _buildSoundTile(context, l10n),
            ],
          ),

          const SizedBox(height: 20),

          // Data & Privacy
          _buildSection(
            l10n.dataPrivacy,
            [
              _buildDataTile(context, l10n),
              _buildPrivacyTile(context, l10n),
              _buildExportTile(context, l10n),
            ],
          ),

          const SizedBox(height: 20),

          // Support & Info
          _buildSection(
            l10n.support,
            [
              _buildHelpTile(context, l10n),
              _buildFeedbackTile(context, l10n),
              _buildAboutTile(context, l10n),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFF3B82F6),
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: const Text(
        'John Doe',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('john.doe@example.com'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to profile editing
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n, LocaleProvider localeProvider) {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF6B7280)),
      title: Text(l10n.language),
      subtitle: Text(localeProvider.locale.languageCode == 'en' ? 'English' : 'Deutsch'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showLanguageDialog(context, l10n, localeProvider);
      },
    );
  }


  Widget _buildNotificationTile(BuildContext context, AppLocalizations l10n) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: Color(0xFF6B7280)),
      title: Text(l10n.notifications),
      subtitle: Text(l10n.receiveUpdates),
      value: notificationsEnabled,
      activeColor: const Color(0xFF3B82F6),
      onChanged: (value) {
        setState(() {
          notificationsEnabled = value;
        });
      },
    );
  }

  Widget _buildLocationTile(BuildContext context, AppLocalizations l10n) {
    return SwitchListTile(
      secondary: const Icon(Icons.location_on, color: Color(0xFF6B7280)),
      title: Text(l10n.locationServices),
      subtitle: Text(l10n.findNearbyPlaces),
      value: locationEnabled,
      activeColor: const Color(0xFF3B82F6),
      onChanged: (value) {
        setState(() {
          locationEnabled = value;
        });
      },
    );
  }

  Widget _buildAutoMarkTile(BuildContext context, AppLocalizations l10n) {
    return SwitchListTile(
      secondary: const Icon(Icons.auto_awesome, color: Color(0xFF6B7280)),
      title: Text(l10n.autoMark),
      subtitle: Text(l10n.autoMarkDescription),
      value: autoMarkNearby,
      activeColor: const Color(0xFF3B82F6),
      onChanged: (value) {
        setState(() {
          autoMarkNearby = value;
        });
      },
    );
  }

  Widget _buildSoundTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.volume_up, color: Color(0xFF6B7280)),
      title: Text(l10n.soundEffects),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.achievementSounds),
          const SizedBox(height: 8),
          Slider(
            value: soundVolume,
            onChanged: (value) {
              setState(() {
                soundVolume = value;
              });
            },
            activeColor: const Color(0xFF3B82F6),
            divisions: 10,
            label: '${(soundVolume * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDataTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.storage, color: Color(0xFF6B7280)),
      title: Text(l10n.manageData),
      subtitle: Text(l10n.clearCache),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showDataDialog(context, l10n);
      },
    );
  }

  Widget _buildPrivacyTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip, color: Color(0xFF6B7280)),
      title: Text(l10n.privacy),
      subtitle: Text(l10n.dataUsage),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to privacy policy
      },
    );
  }

  Widget _buildExportTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.file_download, color: Color(0xFF6B7280)),
      title: Text(l10n.exportData),
      subtitle: Text(l10n.downloadCollections),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Export functionality
        _showExportDialog(context, l10n);
      },
    );
  }

  Widget _buildHelpTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.help, color: Color(0xFF6B7280)),
      title: Text(l10n.help),
      subtitle: Text(l10n.faq),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to help
      },
    );
  }

  Widget _buildFeedbackTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.feedback, color: Color(0xFF6B7280)),
      title: Text(l10n.feedback),
      subtitle: Text(l10n.sendFeedback),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Open feedback form
      },
    );
  }

  Widget _buildAboutTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.info, color: Color(0xFF6B7280)),
      title: Text(l10n.about),
      subtitle: const Text('Version 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showAboutDialog(context, l10n);
      },
    );
  }


  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('🇺🇸 English'),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('🇩🇪 Deutsch'),
              value: 'de',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manageData),
        content: Text(l10n.dataManagementInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Clear cache functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cacheCleared)),
              );
            },
            child: Text(l10n.clearCache),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportData),
        content: Text(l10n.exportDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Export functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportStarted)),
              );
            },
            child: Text(l10n.export),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.collections_bookmark, size: 48),
      children: [
        Text(l10n.aboutDescription),
      ],
    );
  }
}