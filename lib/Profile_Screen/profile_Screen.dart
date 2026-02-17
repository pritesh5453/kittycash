import 'package:flutter/material.dart';
import 'package:kittycash/Main/Dashboard/Dashboard.dart';
import 'package:kittycash/Profile_Screen/KycGettingStartedScreen.dart';
import 'package:kittycash/Refferal_screen/ReferralScreen.dart';
import 'package:kittycash/services/dashboard_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    print("🔥 PROFILE SCREEN INIT");
    loadProfile();
  }

  Future<void> loadProfile() async {
    print("🔥 loadProfile CALLED");

    const token = "16|luMBOYamB5XjCtIOYf48sHW9Tx3KFfPsCaNeRVs08d2689d4";

    final res = await DashboardService().getDashboardProfile(token);
    print("🔥 RESPONSE => $res");

    if (res["status"] == true) {
      profile = res["data"];
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatar;

    if (profile?["profile_image"] != null &&
        profile!["profile_image"].toString().isNotEmpty) {
      avatar = NetworkImage(profile!["profile_image"]);
    } else {
      avatar = const AssetImage("assets/images/profile.png");
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 HEADER (same UI)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E88FF), Color(0xFF2962FF)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            const Icon(Icons.more_vert, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CircleAvatar(radius: 40, backgroundImage: avatar),
                        const SizedBox(height: 12),
                        Text(
                          profile?["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Customer Code : ${profile?["customer_code"] ?? ""}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Edit Profile"),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 MENU (same)
                Expanded(
                  child: ListView(
                    children: [
                      _menuItem(
                        context,
                        Icons.verified_user,
                        "KYC Verification",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KycGettingStartedScreen(),
                          ),
                        ),
                      ),
                      _menuItem(
                        context,
                        Icons.campaign,
                        "Refer & Earn",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReferralScreen(),
                          ),
                        ),
                      ),
                      _menuItem(context, Icons.lock, "Change Password", () {}),
                      _menuItem(
                        context,
                        Icons.help_outline,
                        "Help & Support",
                        () {},
                      ),
                      _menuItem(
                        context,
                        Icons.description,
                        "Terms and Conditions",
                        () {},
                      ),
                      _menuItem(context, Icons.logout, "Logout", () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
