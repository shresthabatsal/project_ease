import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';

// Keys
const _kThemeMode = 'settings_theme_mode';
const _kShakeEnabled = 'settings_shake';

// State
class AppSettings {
  final ThemeMode themeMode;
  final bool shakeEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.shakeEnabled = true,
  });

  AppSettings copyWith({ThemeMode? themeMode, bool? shakeEnabled}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      );
}

// Provider
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

// Notifier
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);

    final mode = switch (prefs.getString(_kThemeMode) ?? 'system') {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return AppSettings(
      themeMode: mode,
      shakeEnabled: prefs.getBool(_kShakeEnabled) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_kThemeMode, str);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setShakeEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kShakeEnabled, enabled);
    state = state.copyWith(shakeEnabled: enabled);
  }
}
