import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarmSound_Provider.dart';
import '../providers/theme_change_provider.dart';
import '../providers/vibration_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsScreen extends StatelessWidget {
  final alarmOptions = {
    'Bedside Alarm': 'assets/bedside-clock-alarm.mp3',
    'Breaking News': 'assets/breaking-news.mp3',
    'Gifts Ringtone': 'assets/gifts-ringtone.mp3',
    'Wind up clock alarm': 'assets/wind-up-clock-alarm-bell.mp3',
  };

  String normalizeAssetPath(String path) {
    return path.replaceFirst('assets/', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Settings',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Theme Mode",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            CupertinoSegmentedControl<ThemeMode>(
              selectedColor: kPrimaryColor,
              children: {
                ThemeMode.system: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("System Default"),
                ),
                ThemeMode.light: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Light Mode"),
                ),
                ThemeMode.dark: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Dark Mode"),
                ),
              },
              onValueChanged: (ThemeMode newValue) {
                context.read<ThemeProvider>().setTheme(newValue);
              },
              groupValue: context.watch<ThemeProvider>().themeMode,
            ),

            SwitchListTile(
              activeColor: kPrimaryColor,
              title: Text("Alarm Vibration"),
              value: context.watch<VibrationProvider>().isVibrationOn,
              onChanged: (bool value) {
                context.read<VibrationProvider>().toggleVibration(value);
              },
            ),

            Text(
              "Select Alarm Sound",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            Consumer<AlarmSoundProvider>(
              builder: (context, alarmProvider, child) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        final player = AudioPlayer();
                        String? currentlyPlaying; // track the path

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return ListView(
                              shrinkWrap: true,
                              children:
                                  alarmOptions.entries.map((entry) {
                                    final isSelected =
                                        alarmProvider.selectedAlarm ==
                                        entry.value;
                                    final isPlaying =
                                        currentlyPlaying == entry.value;

                                    return ListTile(
                                      title: Text(
                                        entry.key,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isPlaying
                                                  ? Icons.stop
                                                  : Icons.play_arrow,
                                              color: kPrimaryColor,
                                            ),
                                            onPressed: () async {
                                              if (isPlaying) {
                                                await player.stop();
                                                setState(
                                                  () => currentlyPlaying = null,
                                                );
                                              } else {
                                                await player.stop();
                                                await player.play(
                                                  AssetSource(
                                                    normalizeAssetPath(
                                                      entry.value,
                                                    ),
                                                  ),
                                                );
                                                setState(
                                                  () =>
                                                      currentlyPlaying =
                                                          entry.value,
                                                );
                                              }
                                            },
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check,
                                              color: kPrimaryColor,
                                            ),
                                        ],
                                      ),
                                      onTap: () async {
                                        alarmProvider.setAlarm(entry.value);
                                        await player
                                            .stop(); // stop sound on selection
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                            );
                          },
                        );
                      },
                    );
                  },

                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border.all(
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alarmOptions.entries
                              .firstWhere(
                                (e) => e.value == alarmProvider.selectedAlarm,
                                orElse: () => alarmOptions.entries.first,
                              )
                              .key,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Text("Alarm Volume", style: Theme.of(context).textTheme.bodyLarge),
            Consumer<AlarmSoundProvider>(
              builder: (context, alarmProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: alarmProvider.alarmVolume,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: alarmProvider.alarmVolume.toStringAsFixed(1),
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        alarmProvider.setVolume(value);
                      },
                    ),
                    Text(
                      "Volume: ${(alarmProvider.alarmVolume * 100).toInt()}%",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
