import 'package:pingo/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // اضافه کردن پکیج easy_localization

class LanguageWidget extends StatefulWidget {
  final String selectedLanguage;

  LanguageWidget({required this.selectedLanguage});

  @override
  _LanguageWidgetState createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        widget.selectedLanguage; // مقدار اولیه را از ورودی دریافت کنید
  }

  // ذخیره زبان انتخاب شده در SharedPreferences
  void _saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  // تغییر زبان با استفاده از easy_localization
  void _changeLocale(BuildContext context, String language) {
    if (language == 'English') {
      setState(() {});
      context.setLocale(Locale('en', 'US'));
      setState(() {});
    } else if (language == 'فارسی') {
      setState(() {});
      context.setLocale(Locale('fa', 'IR'));
      setState(() {});
    } else if (language == '中文') {
      setState(() {});
      context.setLocale(Locale('zh', 'CN'));
      setState(() {});
    } else if (language == 'русский') {
      setState(() {});
      context.setLocale(Locale('ru', 'RU'));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('select_language')),
        backgroundColor: ThemeColor.backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildLanguageTile(context, 'English'),
                  _buildLanguageTile(context, 'فارسی'),
                  _buildLanguageTile(context, '中文'),
                  _buildLanguageTile(context, 'русский'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String language) {
    return ListTile(
      title: Text(language, textAlign: TextAlign.left),
      leading: Radio<String>(
        value: language,
        groupValue: _selectedLanguage,
        onChanged: (String? value) {
          setState(() {
            _selectedLanguage = value!;
            _saveSelectedLanguage(value); // ذخیره زبان انتخاب شده
            _changeLocale(context, value); // تغییر زبان برنامه
          });
        },
      ),
      onTap: () {
        setState(() {
          _selectedLanguage = language;
          _saveSelectedLanguage(language); // ذخیره زبان انتخاب شده
          _changeLocale(context, language); // تغییر زبان برنامه
        });
      },
    );
  }
}
