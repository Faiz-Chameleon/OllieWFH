import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupInfoScreen extends StatefulWidget {
  final dynamic groupDetails;
  const GroupInfoScreen({super.key, required this.groupDetails});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        title: const Text('Group Info'),
        centerTitle: true,
        backgroundColor: Color(0xffFFEECF),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Header
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                        child: const Icon(Icons.people_alt_rounded, size: 40, color: Colors.green),
                      ),
                      Text("", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Group - 19 members', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Group Description
            _buildDescriptionSection(),
            const SizedBox(height: 24),

            // Settings
            _buildSettingsSection(),
            const SizedBox(height: 24),

            // Members Section
            _buildMembersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                child: const Icon(Icons.people_alt_rounded, size: 40, color: Colors.green),
              ),
              const Text('Tea & Tales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Group - 19 members', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add group description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xff1E18180D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // Icon(Icons.edit, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text('Tap to add description...', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      width: 1.sw,

      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: Color(0xff1E18180D)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildSettingTile(icon: Icons.photo_library_rounded, title: 'Shared Media', isEnabled: true),
          _buildSettingTile(icon: Icons.notifications_rounded, title: 'Notifications', isEnabled: false),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required bool isEnabled}) {
    return Container(
      height: 50.h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
            ),
            // Switch(value: isEnabled, onChanged: (value) {}, activeColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: Color(0xff1E18180D)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text('Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 12),
          _buildMemberTile(name: 'You', isYou: true),
          _buildMemberTile(name: 'Margaret'),
          _buildMemberTile(name: 'Eleanor'),
          _buildMemberTile(name: 'Arthur'),
          _buildMemberTile(name: 'Gloria'),
          const SizedBox(height: 8),
          // Text('and 14 more...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMemberTile({required String name, bool isYou = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _getAvatarColor(name), shape: BoxShape.circle),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name + (isYou ? ' (You)' : ''), style: const TextStyle(fontSize: 16))),
          if (isYou)
            Text(
              'Admin',
              style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    final index = name.length % colors.length;
    return colors[index];
  }
}
