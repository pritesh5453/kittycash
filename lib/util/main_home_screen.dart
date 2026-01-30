import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kittycash/Main/Dashboard.dart';
import 'package:kittycash/util/enum.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  final BottomTab initialTab;

  MainHomeScreen({required this.initialTab});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bottomTabProvider.notifier).state = widget.initialTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(bottomTabProvider);

    final Map<BottomTab, Widget> pages = {
      BottomTab.home: HomeDashboardScreen(),
      BottomTab.referrals: HomeDashboardScreen(),
      BottomTab.transactions: HomeDashboardScreen(),
      BottomTab.portfolio: HomeDashboardScreen(),
      BottomTab.support: HomeDashboardScreen(),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ✅ Prevent Page Content from going behind Bottom Nav Bar
          Padding(
            padding: EdgeInsets.only(
              bottom: 100,
            ), // Safe space for navigation bar
            child: pages[selectedTab]!,
          ),

          /// Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 5,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  currentIndex: BottomTab.values.indexOf(selectedTab),
                  onTap: (index) {
                    ref.read(bottomTabProvider.notifier).state =
                        BottomTab.values[index];
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.black87,
                  showUnselectedLabels: true,
                  selectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(fontSize: 12),
                  iconSize: 0,
                  items: [
                    _navItem(
                      Icons.people_outline,
                      "Referrals",
                      selectedTab == BottomTab.referrals,
                    ),
                    _navItem(
                      Icons.history,
                      "Transactions",
                      selectedTab == BottomTab.transactions,
                    ),
                    _navItem(
                      Icons.home_outlined,
                      "Home",
                      selectedTab == BottomTab.home,
                    ),
                    _navItem(
                      Icons.pie_chart_outline,
                      "Profile",
                      selectedTab == BottomTab.portfolio,
                    ),
                    _navItem(
                      Icons.headset_mic_outlined,
                      "Support",
                      selectedTab == BottomTab.support,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return BottomNavigationBarItem(
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: isSelected ? Colors.blue : Colors.transparent,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
          weight: 18,
          size: 18,
        ),
      ),
      label: label,
    );
  }
}
