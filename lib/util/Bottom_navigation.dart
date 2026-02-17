import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kittycash/util/enum.dart';

class CustomBottomNav extends ConsumerWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(bottomTabProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 8,
              left: 16,
              right: 16,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _item(
                      ref,
                      icon: Icons.people_outline,
                      label: "Referrals",
                      tab: BottomTab.referrals,
                      selectedTab: selectedTab,
                    ),
                    _item(
                      ref,
                      icon: Icons.history,
                      label: "Transactions",
                      tab: BottomTab.orders,
                      selectedTab: selectedTab,
                    ),
                    _item(
                      ref,
                      icon: Icons.home_outlined,
                      label: "Home",
                      tab: BottomTab.home,
                      selectedTab: selectedTab,
                    ),
                    _item(
                      ref,
                      icon: Icons.pie_chart_outline,
                      label: "Portfolio",
                      tab: BottomTab.portfolio,
                      selectedTab: selectedTab,
                    ),
                    _item(
                      ref,
                      icon: Icons.headset_mic_outlined,
                      label: "Profile",
                      tab: BottomTab.profile,
                      selectedTab: selectedTab,
                    ),
                  ],
                ),
              ),
            ),

            /// ⚪ iOS INDICATOR
            Positioned(
              bottom: 4,
              child: Container(
                width: 120,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 COMMON ITEM (ALL TABS SAME)
  Widget _item(
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required BottomTab tab,
    required BottomTab selectedTab,
  }) {
    final bool isSelected = tab == selectedTab;

    return GestureDetector(
      onTap: () {
        ref.read(bottomTabProvider.notifier).state = tab;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(
          0,
          isSelected ? -8 : 0, // selected thoda upar
          0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 28 : 22,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
