// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_settings_model.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';

class GameSettingsDialog extends StatefulWidget {
  const GameSettingsDialog({super.key});

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  late CharacterRushSettingsModel _currentSettings;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<CharacterRushProvider>(
      context,
      listen: false,
    );
    _currentSettings = gameProvider.settings;
  }

  void _resetToDefaults() {
    CustomDialog.showConfirmationDialog(
      context: context,
      title: 'Reset Settings',
      content: 'Are you sure you want to reset all settings to default values?',
      confirmText: 'Reset',
      confirmButtonColor: Colors.orange,
      onConfirm: () {
        setState(() {
          _currentSettings = CharacterRushSettingsModel(
            initialSpeed: 1.0,
            speedIncrement: 0.1,
            maxCharacters: 5,
            soundEnabled: true,
          );
        });
      },
    );
  }

  void _saveSettings() {
    final gameProvider = Provider.of<CharacterRushProvider>(
      context,
      listen: false,
    );
    gameProvider.updateSettings(_currentSettings);

    CustomDialog.showSuccessDialog(
      context: context,
      title: 'Settings Saved',
      content: 'Your game settings have been updated successfully.',
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Dialog(
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Game Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'Customize your gaming experience',
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionHeader(
                        'Difficulty Settings',
                        Icons.speed,
                        themeProvider,
                      ),

                      _buildSliderSetting(
                        title: 'Initial Speed',
                        description: 'Starting speed of falling characters',
                        value: _currentSettings.initialSpeed,
                        min: 0.5,
                        max: 3.0,
                        divisions: 25,
                        unit: 'x',
                        onChanged: (value) {
                          setState(() {
                            _currentSettings = _currentSettings.copyWith(
                              initialSpeed: value,
                            );
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      _buildSliderSetting(
                        title: 'Speed Increment',
                        description:
                            'How much speed increases every 10 seconds',
                        value: _currentSettings.speedIncrement,
                        min: 0.05,
                        max: 0.9,
                        divisions: 9,
                        unit: 'x',
                        onChanged: (value) {
                          setState(() {
                            _currentSettings = _currentSettings.copyWith(
                              speedIncrement: value,
                            );
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      _buildSliderSetting(
                        title: 'Max Characters',
                        description: 'Maximum characters on screen at once',
                        value: _currentSettings.maxCharacters.toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        unit: '',
                        isInt: true,
                        onChanged: (value) {
                          setState(() {
                            _currentSettings = _currentSettings.copyWith(
                              maxCharacters: value.toInt(),
                            );
                          });
                        },
                        themeProvider: themeProvider,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionHeader(
                        'Game Preferences',
                        Icons.settings,
                        themeProvider,
                      ),

                      _buildToggleSetting(
                        title: 'Sound Effects',
                        description: 'Enable or disable game sounds',
                        value: _currentSettings.soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _currentSettings = _currentSettings.copyWith(
                              soundEnabled: value,
                            );
                          });
                        },
                        themeProvider: themeProvider,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetToDefaults,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Reset to Defaults'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: themeProvider.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required Function(double) onChanged,
    required ThemeProvider themeProvider,
    bool isInt = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isInt ? value.toInt() : value.toStringAsFixed(2)}$unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: themeProvider.primaryColor,
            inactiveColor:
                themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[300],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isInt ? min.toInt() : min.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
              Text(
                '${isInt ? max.toInt() : max.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: themeProvider.primaryColor,
          ),
        ],
      ),
    );
  }
}
