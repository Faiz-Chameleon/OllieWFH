import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/myprofile/delete_account_dialouge.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _personalizedAds = true;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Manage What You Share
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'MANAGE WHAT YOU SHARE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            _buildPrivacyCard(),
            const SizedBox(height: 24),

            // Section 2: How We Protect It
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'HOW WE PROTECT IT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            // _buildSecurityCard(),
            const SizedBox(height: 24),

            // Account Actions
            _buildAccountActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Profile Privacy
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: const Text('Profile Privacy'),
            subtitle: const Text('Control who sees your information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showProfilePrivacyDialog(),
          ),
          // const Divider(height: 1),

          // Apps and Websites
          // ListTile(
          //   leading: const Icon(Icons.language, color: Colors.green),
          //   title: const Text('Apps and Websites'),
          //   subtitle: const Text('3 apps connected'),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () => _showConnectedAppsDialog(),
          // ),
          // const Divider(height: 1),

          // Ad Preferences
          // ListTile(
          //   leading: const Icon(Icons.ad_units_outlined, color: Colors.orange),
          //   title: const Text('Ad Preferences'),
          //   subtitle: Text(_personalizedAds ? 'Personalized ads on' : 'Personalized ads off'),
          //   trailing: Switch(
          //     value: _personalizedAds,
          //     onChanged: (value) {
          //       setState(() {
          //         _personalizedAds = value;
          //       });
          //     },
          //   ),
          // ),
          // const Divider(height: 1),

          // Download Data Button
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: OutlinedButton.icon(
          //       icon: const Icon(Icons.file_download_outlined),
          //       label: const Text('Request Your Data'),
          //       onPressed: () => _requestDataDownload(),
          //       style: OutlinedButton.styleFrom(
          //         foregroundColor: Colors.blue,
          //         padding: const EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Two-Factor Authentication
          // ListTile(
          //   leading: const Icon(Icons.security, color: Colors.purple),
          //   title: const Text('Two-Factor Authentication'),
          //   subtitle: Text(_twoFactorAuth ? 'Enabled' : 'Not set up'),
          //   trailing: Switch(
          //     value: _twoFactorAuth,
          //     onChanged: (value) {
          //       setState(() {
          //         _twoFactorAuth = value;
          //       });
          //     },
          //   ),
          // ),
          const Divider(height: 1),

          // Active Sessions
          // ListTile(
          //   leading: const Icon(Icons.devices, color: Colors.teal),
          //   title: const Text('Active Sessions'),
          //   subtitle: const Text('2 devices connected'),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () => _showActiveSessionsDialog(),
          // ),
          const Divider(height: 1),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.red),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePasswordDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // How We Protect Info
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text('How We Protect Your Data'),
            subtitle: Text('We use encryption to protect your data. Our security teams work to prevent unauthorized access.'),
          ),
          const Divider(height: 1),

          // Privacy Policy Link
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.grey),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(),
          ),
          const Divider(height: 1),

          // Delete Account - Red option
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Deactivate or Delete Account', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: () {
              showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Placeholder functions for dialog actions
  void _showProfilePrivacyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Profile Privacy'),
        content: const Text('Profile privacy options are not applicable for this app.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
      ),
    );
  }

  void _showConnectedAppsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Connected Apps'),
        content: const Text('List of apps with access to your account would appear here.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
      ),
    );
  }

  void _requestDataDownload() {
    Get.snackbar(
      'Request Received',
      'Your data download will be prepared and sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
    );
  }

  void _showActiveSessionsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Active Sessions'),
        content: const Text('List of devices where your account is currently logged in would appear here.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
      ),
    );
  }

  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change form would appear here.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(child: Text('Full privacy policy text would appear here...')),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              showDeleteAccountDialog(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
