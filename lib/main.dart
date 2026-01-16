import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/app.dart';
import 'package:project_ease/core/services/hive/hive_service.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();

  // Shared Prefs
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: App(),
    ),
  );
}