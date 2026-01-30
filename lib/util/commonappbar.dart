import 'package:flutter/material.dart';

class CommonAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final String? profileImage;

  const CommonAppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.profileImage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D3F76),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: onNotificationTap,
              ),
              CircleAvatar(
                radius: 18,
                backgroundImage: profileImage != null
                    ? AssetImage(profileImage!)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
