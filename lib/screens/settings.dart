import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile(
              value: false,
              title: const Text("Theme"),
              onChanged: (value) {},
            ),
          ],
        ),
      )
    );
  }
}
