import 'package:flutter_riverpod/legacy.dart';
import 'package:kittycash/util/enum.dart';

final bottomTabProvider = StateProvider<BottomTab>((ref) {
  return BottomTab.home;
});
