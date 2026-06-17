import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/CareCircle/groups/group_shared_media_screen.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class GroupInfoScreen extends StatefulWidget {
  final MyGroupsData groupDetails;
  final String? chatRoomId;

  const GroupInfoScreen({
    super.key,
    required this.groupDetails,
    this.chatRoomId,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final userController = Get.find<UserController>();
  final OneToManyChatController groupChatController =
      Get.find<OneToManyChatController>();

  late List<_GroupMemberEntry> members;

  @override
  void initState() {
    super.initState();
    members = _buildMembers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_canReviewJoinRequests && _isPrivateGroup) {
        groupChatController.fetchGroupJoinRequests(_resolvedChatRoomId);
      }
    });
  }

  String get _loggedInUserId => userController.user.value?.id ?? '';
  String? get _creatorId =>
      widget.groupDetails.creatorId?.trim().isNotEmpty == true
      ? widget.groupDetails.creatorId!.trim()
      : null;
  bool get _isCreator => widget.groupDetails.isCurrentUserCreator == true;
  bool get _isAdmin => members.any(
    (member) => member.id == _loggedInUserId && member.memberType == 'ADMIN',
  );
  bool get _canReviewJoinRequests => _isCreator || _isAdmin;
  bool get _isPrivateGroup =>
      widget.groupDetails.groupPrivacy?.toUpperCase() == 'PRIVATE';

  String get _resolvedChatRoomId => widget.chatRoomId?.trim().isNotEmpty == true
      ? widget.chatRoomId!.trim()
      : groupChatController.groupConversationId.value.trim();

  List<_GroupMemberEntry> _buildMembers() {
    final participantUsers =
        widget.groupDetails.participants?.users ?? const <Users>[];
    final participantAdmins =
        widget.groupDetails.participants?.admins ?? const <GroupAdmin>[];

    final entries = <_GroupMemberEntry>[
      ...participantAdmins.map(
        (admin) => _GroupMemberEntry(
          id: admin.id ?? '',
          firstName: admin.firstName,
          lastName: admin.lastName,
          image: admin.image,
          memberType: 'ADMIN',
        ),
      ),
      ...participantUsers
          .where(
            (user) => !participantAdmins.any((admin) => admin.id == user.id),
          )
          .map(
            (user) => _GroupMemberEntry(
              id: user.id ?? '',
              firstName: user.firstName,
              lastName: user.lastName,
              image: user.image,
              memberType: 'USER',
            ),
          ),
    ];

    return entries;
  }

  String _memberName(_GroupMemberEntry member) {
    final firstName = member.firstName?.trim() ?? '';
    final lastName = member.lastName?.trim() ?? '';
    final fullName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');
    return fullName.isNotEmpty ? fullName : 'Unknown Member';
  }

  ImageProvider _avatarProvider(String? imageUrl, String name) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      return NetworkImage(trimmedUrl);
    }
    return AssetImage(
      name.isNotEmpty
          ? 'assets/icons/Group 1000000907 (1).png'
          : 'assets/icons/Group 1000000907 (1).png',
    );
  }

  Widget _buildGroupAvatar() {
    final imageUrl = widget.groupDetails.image?.trim() ?? '';
    if (imageUrl.isEmpty) {
      return _buildGroupAvatarFallback();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildGroupAvatarFallback(),
      ),
    );
  }

  Widget _buildGroupAvatarFallback() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green[100],
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.people_alt_rounded,
        size: 40,
        color: Colors.green,
      ),
    );
  }

  Future<void> _removeMember(_GroupMemberEntry member) async {
    final chatRoomId = _resolvedChatRoomId;
    if (chatRoomId.isEmpty || member.id.isEmpty) {
      appSnackbar("Error", "Unable to remove this member right now");
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Remove ${_memberName(member)} from this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    final removed = await groupChatController
        .removeParticipantFromGroupChatRoom(
          chatRoomId,
          member.id,
          memberType: member.memberType,
        );

    if (!removed) {
      return;
    }

    setState(() {
      members.removeWhere((item) => item.id == member.id);
      widget.groupDetails.participants?.users = members
          .where((item) => item.memberType == 'USER')
          .map(
            (item) => Users(
              id: item.id,
              firstName: item.firstName,
              lastName: item.lastName,
              image: item.image,
            ),
          )
          .toList();
      widget.groupDetails.participants?.admins = members
          .where((item) => item.memberType == 'ADMIN')
          .map(
            (item) => GroupAdmin(
              id: item.id,
              firstName: item.firstName,
              lastName: item.lastName,
              image: item.image,
            ),
          )
          .toList();
      widget.groupDetails.participants?.adminIds = members
          .where((item) => item.memberType == 'ADMIN')
          .map((item) => item.id)
          .toList();
      if ((widget.groupDetails.memberCount ?? 0) > 0) {
        widget.groupDetails.memberCount = members.length;
      }
    });
  }

  Future<void> _leaveGroup() async {
    final chatRoomId = _resolvedChatRoomId;
    if (chatRoomId.isEmpty) {
      appSnackbar("Error", "Unable to leave this group right now");
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Group'),
          content: const Text('Are you sure you want to leave this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true) return;

    final left = await groupChatController.leaveGroupChatRoom(chatRoomId);
    if (left) {
      Get.back();
      Get.back();
    }
  }

  String _requestId(Map<String, dynamic> request) {
    return (request['id'] ?? request['requestId'] ?? '').toString();
  }

  String _requesterName(Map<String, dynamic> request) {
    final requester =
        request['requester'] ?? request['user'] ?? request['member'];
    if (requester is Map) {
      final first = requester['firstName']?.toString().trim() ?? '';
      final last = requester['lastName']?.toString().trim() ?? '';
      final fullName = [first, last].where((part) => part.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) return fullName;

      final name = requester['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }

    return request['userName']?.toString() ??
        request['requesterName']?.toString() ??
        'Pending member';
  }

  Widget _buildPendingRequestsSection() {
    if (!_canReviewJoinRequests || !_isPrivateGroup) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (groupChatController.groupJoinRequestsStatus.value ==
          RequestStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      final requests = groupChatController.groupJoinRequests;
      if (requests.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: 1.sw,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: const Color(0x1E18180D),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pending Requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            ...requests.map((request) => _buildJoinRequestTile(request)),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget _buildJoinRequestTile(Map<String, dynamic> request) {
    final requestId = _requestId(request);
    final name = _requesterName(request);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person_rounded)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Obx(() {
            final isReviewing =
                groupChatController.reviewGroupJoinRequestStatus.value ==
                RequestStatus.loading;
            return Row(
              children: [
                IconButton(
                  onPressed: isReviewing
                      ? null
                      : () => groupChatController.reviewGroupJoinRequest(
                          requestId,
                          'REJECT',
                        ),
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton(
                  onPressed: isReviewing
                      ? null
                      : () async {
                          final approved = await groupChatController
                              .reviewGroupJoinRequest(requestId, 'APPROVE');
                          if (approved) {
                            groupChatController.fetchGroupJoinRequests(
                              _resolvedChatRoomId,
                            );
                          }
                        },
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        title: const Text('Group Info'),
        centerTitle: true,
        backgroundColor: const Color(0xffFFEECF),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildGroupAvatar(),
                      Text(
                        widget.groupDetails.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Group - ${members.length} members',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x1E18180D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.groupDetails.description ?? '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPendingRequestsSection(),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: const Color(0x1E18180D),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Members',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    itemCount: members.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberTile(member: member);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: const Color(0x1E18180D),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.photo_library_rounded,
            title: 'Shared Media',
            onTap: () {
              final chatRoomId = _resolvedChatRoomId;
              if (chatRoomId.isEmpty) {
                appSnackbar("Error", "Unable to open shared media right now");
                return;
              }
              Get.to(() => GroupSharedMediaScreen(chatRoomId: chatRoomId));
            },
          ),
          _buildSettingTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
          ),
          if (!_isCreator)
            Obx(() {
              final isLeaving =
                  groupChatController.leaveGroupRequestStatus.value ==
                  RequestStatus.loading;
              return _buildSettingTile(
                icon: Icons.logout_rounded,
                title: isLeaving ? 'Leaving...' : 'Leave Group',
                color: Colors.red.shade700,
                onTap: isLeaving ? null : _leaveGroup,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50.h,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({required _GroupMemberEntry member}) {
    final name = _memberName(member);
    final isCurrentUser = member.id == _loggedInUserId;
    final canRemove = _isCreator && !isCurrentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _avatarProvider(member.image, name),
            child: (member.image?.trim().isNotEmpty ?? false)
                ? null
                : Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16)),
                if (member.id == _creatorId)
                  Text(
                    'Creator',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (member.memberType == 'ADMIN')
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.blueGrey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isCurrentUser)
                  Text(
                    'You',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (canRemove)
            Obx(() {
              final isRemoving =
                  groupChatController.removeParticipantRequestStatus.value ==
                  RequestStatus.loading;
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeMember(member);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove member'),
                  ),
                ],
                enabled: !isRemoving,
                child: isRemoving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.more_vert, color: Colors.black),
              );
            }),
        ],
      ),
    );
  }
}

class _GroupMemberEntry {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String memberType;

  const _GroupMemberEntry({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.memberType,
  });
}
