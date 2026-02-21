import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kittycash/Auth/Login/login_screen.dart';
import 'package:kittycash/Profile_Screen/edit_profile_screen.dart';
import 'package:kittycash/Profile_Screen/kyc_screen.dart';
import 'package:kittycash/Refferal_screen/ReferralScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, Object? profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// ================= LOAD PROFILE =================

  Future<void> loadProfile() async {
    try {
      final token = await storage.read(key: "auth_token");

      print("TOKEN: $token");

      if (token == null) {
        setState(() => loading = false);
        return;
      }

      final response = await dio.get(
        "https://kittycash.co.in/api/dashboard/profile",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("FULL RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data["success"] == true) {
        setState(() {
          profile = response.data["data"]; // 🔥 FIXED HERE
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Profile Error: $e");
      setState(() => loading = false);
    }
  }

  /// ================= LOGOUT FUNCTION =================

  Future<void> logoutUser() async {
    try {
      final token = await storage.read(key: "auth_token");

      if (token == null) return;

      final response = await dio.post(
        "https://kittycash.co.in/api/logout",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("LOGOUT RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data["status"] == true) {
        await storage.delete(key: "auth_token");

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  /// ================= LOGOUT CONFIRMATION =================

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await logoutUser();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
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
                /// 🔹 HEADER
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

                        Text(
                          "Customer Code : ${profile?["id"] ?? ""}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(name: profile?["name"]),
                              ),
                            );
                          },
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

                /// 🔹 MENU
                Expanded(
                  child: ListView(
                    children: [
                      _menuItem(
                        context,
                        Icons.verified_user,
                        "KYC Verification",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KycScreen()),
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
                      _menuItem(
                        context,
                        Icons.logout,
                        "Logout",
                        showLogoutDialog,
                      ),
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
