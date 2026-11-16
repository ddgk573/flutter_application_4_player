import 'package:flutter/foundation.dart';

const int kPlayerTab = 2; // индекс вкладки «Play» в main.dart

/// Текущая вкладка нижней навигации (по умолчанию открывается плеер)
final ValueNotifier<int> currentTab = ValueNotifier<int>(kPlayerTab);
