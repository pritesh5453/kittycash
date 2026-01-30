import 'package:flutter_riverpod/legacy.dart';

final bottomTabProvider = StateProvider<BottomTab>((ref) {
  return BottomTab.home;
});

enum BottomTab { referrals, transactions, home, portfolio, support }
