import 'package:flutter_riverpod/legacy.dart';

final onboardingIndexProvider = StateProvider<int>((ref) => 0);
final homeTabKeyProvider = StateProvider<int>((ref) => 0);
final shopTabKeyProvider = StateProvider<int>((ref) => 0);
final wishlistTabKeyProvider = StateProvider<int>((ref) => 0);