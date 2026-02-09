import 'package:pingo/common/theme.dart';
import 'package:pingo/widgets/settings/blocked_apps_widget.dart';
import 'package:pingo/widgets/settings/language_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  SettingsWidget({super.key});

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  // بارگذاری زبان از SharedPreferences
  void _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('setting'),
          style: TextStyle(color: ThemeColor.foregroundColor, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo_transparent.png',
              color: ThemeColor.foregroundColor,
              height: 50,
            ),
          ),
        ],
        backgroundColor: ThemeColor.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: ThemeColor.backgroundColor,
      body: SettingsList(
        contentPadding: EdgeInsets.all(20),
        brightness: Brightness.dark,
        darkTheme: SettingsThemeData(
          settingsSectionBackground: Color(0xff192028),
          settingsListBackground: Color(0xff192028),
        ),
        sections: [
          SettingsSection(
            title: Text(
              context.tr('blocking_settings'),
              style: TextStyle(fontFamily: 'sm'),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(
                  context.tr('block_application'),
                  style: TextStyle(fontFamily: 'sb'),
                ),
                leading: Icon(Icons.block),
                description: Text(
                  context.tr('block_detail'),
                  style: TextStyle(fontFamily: 'sm', fontSize: 12),
                ),
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlockedAppsWidgets(),
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              context.tr('language_settings'),
              style: TextStyle(fontFamily: 'sm'),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(
                  context.tr('language'),
                  style: TextStyle(fontFamily: 'sb'),
                ),
                leading: Icon(Icons.language),
                description: _selectedLanguage != null
                    ? Text(
                        _selectedLanguage!,
                        style: TextStyle(fontFamily: 'sm', fontSize: 12),
                      )
                    : null,
                onPressed: (context) {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => LanguageWidget(
                        selectedLanguage: _selectedLanguage!,
                      ),
                    ),
                  )
                      .then((value) {
                    _loadSelectedLanguage();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
