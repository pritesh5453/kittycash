// import 'dart:convert';
// import 'package:http/http.dart' as http;
// class DashboardService {
//   static const String baseUrl = "https://kittycash.co.in/api";

//   Future<Map<String, dynamic>> getDashboardProfile(String token) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/dashboard/profile"),
//       headers: {
//         "Accept": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {"status": true, "data": data};
//     } else {
//       return {"status": false};
//     }
//   }
// }

// class CryptoHomeScreen extends StatefulWidget {
//   const CryptoHomeScreen({super.key});

//   @override
//   State<CryptoHomeScreen> createState() => _CryptoHomeScreenState();
// }

// class _CryptoHomeScreenState extends State<CryptoHomeScreen> {
//   Map<String, dynamic>? profile;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadDashboard();
//   }

//   /// ✅ SAME FILE, BUT INSIDE STATE CLASS
//   Future<void> loadDashboard() async {
//     try {
//       const token = "16|luMBOYamB5XjCtIOYf48sHW9Tx3KFfPsCaNeRVs08d2689d4";

//       final res = await DashboardService().getDashboardProfile(token);

//       if (res["status"] == true) {
//         final responseData = res["data"];
//         if (responseData is Map<String, dynamic>) {
//           setState(() {
//             profile = responseData.containsKey("data")
//                 ? responseData["data"]
//                 : responseData;
//           });
//         }
//       }
//     } catch (e) {
//       print("❌ DASHBOARD ERROR: $e");
//     } finally {
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: Center(
//         child: Text("Welcome ${profile?['name'] ?? ''}"),
//       ),
//     );
//   }
// }
