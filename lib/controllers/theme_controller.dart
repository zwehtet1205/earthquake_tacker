import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs; // Default to light mode

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    // Force a rebuild of the app
    Get.forceAppUpdate();
  }

  ThemeMode get currentThemeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}