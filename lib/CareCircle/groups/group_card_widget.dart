import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/common/common.dart';

class GroupCardWidget extends StatelessWidget {
  final String title;
  final String members;
  final String action;
  final String imagePath;
  final List<Users> membersImages;
  final bool joined;
  final double? width;

  const GroupCardWidget({
    super.key,
    required this.title,
    required this.members,
    required this.action,
    required this.imagePath,
    required this.membersImages,
    required this.joined,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final memberImages = membersImages.take(2).map((p) => p.image ?? "").toList();
    final validMemberImages = memberImages.where((image) => image.trim().isNotEmpty).toList();

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8D8BB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 104.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: const LinearGradient(
                colors: [Color(0xFFF6D58C), Color(0xFFECA95F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF4E4C3),
                        alignment: Alignment.center,
                        child: Icon(Icons.groups_rounded, size: 42, color: Colors.brown.shade400),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [Color(0x12000000), Color(0x9A000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsiveFontSize(20, min: 18, max: 24),
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xE6FFF4D7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          action,
                          style: TextStyle(
                            color: const Color(0xFF4B3510),
                            fontSize: responsiveFontSize(14, min: 13, max: 18),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    joined ? 'Already active in this circle' : 'Discover and connect with this circle',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF6E6256),
                      fontSize: responsiveFontSize(15, min: 13, max: 18),
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7E8C9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 22,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (validMemberImages.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(validMemberImages[0]),
                                  ),
                                )
                              else
                                const Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Color(0xFFD8C6A6),
                                    child: Icon(Icons.person, size: 14, color: Colors.white),
                                  ),
                                ),
                              if (validMemberImages.length > 1)
                                Positioned(
                                  left: 16,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(validMemberImages[1]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$members members',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF2F241B),
                              fontSize: responsiveFontSize(15, min: 13, max: 18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: joined ? const Color(0xFF7BB662) : const Color(0xFFE59A48),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
