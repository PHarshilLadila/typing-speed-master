// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_settings_model.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/word_master/model/word_master_settings_model.dart';
import 'package:typing_speed_master/features/games/word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';

class GameSettingsDialog extends StatefulWidget {
  final bool isWordMaster;
  const GameSettingsDialog({super.key, this.isWordMaster = false});

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  late CharacterRushSettingsModel characterRushSettings;
  late WordMasterSettingsModel wordMasterSettings;

  @override
  void initState() {
    super.initState();
    final charRushProvider = Provider.of<CharacterRushProvider>(
      context,
      listen: false,
    );
    final wordMasterProvider = Provider.of<WordMasterProvider>(
      context,
      listen: false,
    );
    characterRushSettings = charRushProvider.settings;
    wordMasterSettings = wordMasterProvider.settings;
  }

  void gameResetToDefaults() {
    CustomDialog.showConfirmationDialog(
      context: context,
      title: 'Reset Settings',
      content: 'Are you sure you want to reset all settings to default values?',
      confirmText: 'Reset',
      confirmButtonColor: Colors.orange,
      onConfirm: () {
        widget.isWordMaster == true
            ? setState(() {
              wordMasterSettings = WordMasterSettingsModel(
                initialSpeed: 1.0,
                speedIncrement: 0.1,
                maxWords: 5,
                soundEnabled: true,
              );
            })
            : setState(() {
              characterRushSettings = CharacterRushSettingsModel(
                initialSpeed: 1.0,
                speedIncrement: 0.1,
                maxCharacters: 5,
                soundEnabled: true,
              );
            });
      },
    );
  }

  void gameSaveSettings() {
    final charRushProvider = Provider.of<CharacterRushProvider>(
      context,
      listen: false,
    );
    final wordMasterProvider = Provider.of<WordMasterProvider>(
      context,
      listen: false,
    );

    widget.isWordMaster == true
        ? wordMasterProvider.updateSettings(wordMasterSettings)
        : charRushProvider.updateSettings(characterRushSettings);

    CustomDialog.showSuccessDialog(
      context: context,
      title: 'Settings Saved',
      content: 'Your game settings have been updated successfully.',
      onPressed: () {
        context.pop();
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
                      charRushSettingHeader(
                        'Difficulty Settings',
                        Icons.speed,
                        themeProvider,
                      ),

                      charRushSliderSetting(
                        title: 'Initial Speed',
                        description: 'Starting speed of falling characters',
                        value:
                            widget.isWordMaster == true
                                ? wordMasterSettings.initialSpeed
                                : characterRushSettings.initialSpeed,
                        min: 0.5,
                        max: 3.0,
                        divisions: 25,
                        unit: 'x',
                        onChanged: (value) {
                          widget.isWordMaster == true
                              ? setState(() {
                                wordMasterSettings = wordMasterSettings
                                    .copyWith(initialSpeed: value);
                              })
                              : setState(() {
                                characterRushSettings = characterRushSettings
                                    .copyWith(initialSpeed: value);
                              });
                        },
                        themeProvider: themeProvider,
                      ),

                      charRushSliderSetting(
                        title: 'Speed Increment',
                        description:
                            'How much speed increases every 10 seconds',
                        value:
                            widget.isWordMaster == true
                                ? wordMasterSettings.speedIncrement
                                : characterRushSettings.speedIncrement,
                        min: 0.05,
                        max: 0.9,
                        divisions: 9,
                        unit: 'x',
                        onChanged: (value) {
                          widget.isWordMaster == true
                              ? setState(() {
                                wordMasterSettings = wordMasterSettings
                                    .copyWith(speedIncrement: value);
                              })
                              : setState(() {
                                characterRushSettings = characterRushSettings
                                    .copyWith(speedIncrement: value);
                              });
                        },
                        themeProvider: themeProvider,
                      ),

                      charRushSliderSetting(
                        title:
                            widget.isWordMaster == true
                                ? "Max Words"
                                : 'Max Characters',
                        description:
                            widget.isWordMaster == true
                                ? " Maximum Words on screen at once"
                                : 'Maximum characters on screen at once',
                        value:
                            widget.isWordMaster == true
                                ? wordMasterSettings.maxWords.toDouble()
                                : characterRushSettings.maxCharacters
                                    .toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        unit: '',
                        isInt: true,
                        onChanged: (value) {
                          widget.isWordMaster == true
                              ? setState(() {
                                wordMasterSettings = wordMasterSettings
                                    .copyWith(maxWords: value.toInt());
                              })
                              : setState(() {
                                characterRushSettings = characterRushSettings
                                    .copyWith(maxCharacters: value.toInt());
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
                      onPressed: gameResetToDefaults,
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
                      onPressed: gameSaveSettings,
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

  Widget charRushSettingHeader(
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

  Widget charRushSliderSetting({
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
}
