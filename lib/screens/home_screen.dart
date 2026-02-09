import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pingo/common/cha.dart';
import 'package:pingo/common/config.dart';
import 'package:pingo/common/http_client.dart';
import 'package:pingo/common/secure_storage.dart';
import 'package:pingo/widgets/connection_widget.dart';
import 'package:pingo/widgets/server_selection_modal_widget.dart';
import 'package:pingo/widgets/vpn_status.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/theme.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  late final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      v2rayStatus.value = status;
    },
  );

  bool proxyOnly = false;
  List<String> bypassSubnets = [];
  String? coreVersion;
  String? versionName;
  bool isLoading = false;
  int? connectedServerDelay;
  late SharedPreferences _prefs;
  String selectedServer = 'Automatic';
  String? selectedServerLogo;
  String? domainName;
  bool isFetchingPing = false;
  List<String> blockedApps = [];

  @override
  void initState() {
    super.initState();
    
    try {
      if (AppConfig.enableDebugLogs) {
        print('🐦 Pingo: initState started');
        print('🐦 Test Mode: ${AppConfig.isTestMode}');
      }
      
      getVersionName();
      _loadServerSelection();
      
      // در حالت تست، V2Ray رو initialize نمی‌کنیم
      if (!AppConfig.isTestMode) {
        if (AppConfig.enableDebugLogs) {
          print('🐦 Initializing V2Ray...');
        }
        flutterV2ray
            .initializeV2Ray(
          notificationIconResourceType: "mipmap",
          notificationIconResourceName: "launcher_icon",
        )
            .then((value) async {
          if (AppConfig.enableDebugLogs) {
            print('🐦 V2Ray initialized successfully');
          }
          coreVersion = await flutterV2ray.getCoreVersion();

          setState(() {});
          Future.delayed(
            Duration(seconds: 1),
            () {
              if (v2rayStatus.value.state == 'CONNECTED') {
                delay();
              }
            },
          );
        }).catchError((error) {
          if (AppConfig.enableDebugLogs) {
            print('🐦 V2Ray initialization error: $error');
          }
        });
      } else {
        // حالت تست - فقط برای نمایش UI
        if (AppConfig.enableDebugLogs) {
          print('🐦 Running in TEST MODE - VPN disabled');
        }
        // مقدار پیش‌فرض برای coreVersion
        coreVersion = 'Test Mode';
      }
      
      if (AppConfig.enableDebugLogs) {
        print('🐦 Pingo: initState completed');
      }
    } catch (e, stackTrace) {
      print('🐦 ERROR in initState: $e');
      print('🐦 Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final size = MediaQuery.sizeOf(context);
      final bool isWideScreen = size.width > 600;

      return Scaffold(
      appBar: isWideScreen ? null : _buildAppBar(isWideScreen),
      backgroundColor: const Color(0xff192028),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showServerSelectionModal(context),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Lottie.asset(
                      selectedServerLogo ?? 'assets/lottie/auto.json',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedServer,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        fontFamily: 'GM',
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: v2rayStatus,
                  builder: (context, value, child) {
                    final size = MediaQuery.sizeOf(context);
                    final bool isWideScreen = size.width > 600;
                    return isWideScreen
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ConnectionWidget(
                                          onTap: () =>
                                              _handleConnectionTap(value),
                                          isLoading: isLoading,
                                          status: value.state,
                                        ),
                                        if (value.state == 'CONNECTED') ...[
                                          const SizedBox(height: 16),
                                          _buildDelayIndicator(),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (value.state == 'CONNECTED') ...[
                                    Expanded(
                                      child: VpnCard(
                                        download: value.download,
                                        upload: value.upload,
                                        downloadSpeed: value.downloadSpeed,
                                        uploadSpeed: value.uploadSpeed,
                                        selectedServer: selectedServer,
                                        selectedServerLogo:
                                            selectedServerLogo ??
                                                'assets/lottie/auto.json',
                                        duration: value.duration,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConnectionWidget(
                                onTap: () => _handleConnectionTap(value),
                                isLoading: isLoading,
                                status: value.state,
                              ),
                              if (value.state == 'CONNECTED') ...[
                                const SizedBox(height: 16),
                                _buildDelayIndicator(),
                                const SizedBox(height: 60),
                                VpnCard(
                                  download: value.download,
                                  upload: value.upload,
                                  downloadSpeed: value.downloadSpeed,
                                  uploadSpeed: value.uploadSpeed,
                                  selectedServer: selectedServer,
                                  selectedServerLogo: selectedServerLogo ??
                                      'assets/lottie/auto.json',
                                  duration: value.duration,
                                ),
                              ],
                            ],
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    } catch (e, stackTrace) {
      print('🐦 ERROR in build: $e');
      print('🐦 Stack trace: $stackTrace');
      // نمایش صفحه خطا
      return Scaffold(
        backgroundColor: const Color(0xff192028),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Error loading app',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  e.toString(),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    return AppBar(
      title: Text(
        context.tr('app_title'),
        style: TextStyle(
          color: ThemeColor.foregroundColor,
          fontSize: isWideScreen ? 22 : 18,
        ),
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
      automaticallyImplyLeading: !isWideScreen,
      centerTitle: true,
      backgroundColor: ThemeColor.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildDelayIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      width: connectedServerDelay == null ? 50 : 90,
      height: 30,
      child: Center(
        child: connectedServerDelay == null
            ? LoadingAnimationWidget.fallingDot(
                color: const Color.fromARGB(255, 214, 182, 0),
                size: 35,
              )
            : _buildDelayDisplay(),
      ),
    );
  }

  Widget _buildDelayDisplay() {
    return SizedBox(
      height: 50,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: delay,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.wifi, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              connectedServerDelay.toString(),
              style: TextStyle(fontFamily: 'GM'),
            ),
            const SizedBox(width: 4),
            const Text('ms'),
          ],
        ),
      ),
    );
  }

  void _handleConnectionTap(V2RayStatus value) async {
    if (value.state == "DISCONNECTED") {
      getDomain();
      // initKey();
    } else {
      flutterV2ray.stopV2Ray();
    }
  }

  void _showServerSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return ServerSelectionModal(
          selectedServer: selectedServer,
          onServerSelected: (server) {
            if (v2rayStatus.value.state == "DISCONNECTED") {
              String? logoPath;
              if (server == 'Automatic') {
                logoPath = 'assets/lottie/auto.json';
              } else if (server == 'Server 1') {
                logoPath = 'assets/lottie/server.json';
              } else if (server == 'Server 2') {
                logoPath = 'assets/lottie/server.json';
              }
              setState(() {
                selectedServer = server;
              });
              _saveServerSelection(server, logoPath!);
              Navigator.pop(context);
            } else {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr('error_change_server'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  String getServerParam() {
    if (selectedServer == 'Server 1') {
      return 'server_1';
    } else if (selectedServer == 'Server 2') {
      return 'server_2';
    } else {
      return 'auto';
    }
  }

  Future<void> _loadServerSelection() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedServer = _prefs.getString('selectedServers') ?? 'Automatic';
      selectedServerLogo =
          _prefs.getString('selectedServerLogos') ?? 'assets/lottie/auto.json';
    });
  }

  Future<void> _saveServerSelection(String server, String logoPath) async {
    await _prefs.setString('selectedServers', server);
    await _prefs.setString('selectedServerLogos', logoPath);
    setState(() {
      selectedServer = server;
      selectedServerLogo = logoPath;
    });
  }

  Future<List<String>> getDeviceArchitecture() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.supportedAbis;
  }

  void getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
    });
  }

  Future<void> getDomain() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isLoading = true;
        blockedApps = prefs.getStringList('blockedApps') ?? [];
      });
      final response = await httpClient.get('').timeout(
        Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException(context.tr('error_timeout'));
        },
      );
      domainName = response.data;
      checkUpdate();
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message!,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('error_domain')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String decrypt(String secureData, String x1, String x2, String key) {
    final encryptedData = {
      'ciphertext': secureData, // secure
      'nonce': x1, // x1
      'tag': x2 // x2
    };
    final savedKey = key;
    try {
      final decrypted = Decryptor.decryptChaCha20(encryptedData, savedKey);
      return decrypted.toString();
    } catch (e) {
      return 'Error during decryption: $e';
    }
  }

  void checkUpdate() async {
    try {
      final serverParam = getServerParam();

      String userKey = await storage.read(key: 'user') ?? '';
      if (userKey == '') {
        final response = await Dio()
            .get(
          "https://$domainName/api/firebase/init/android",
          options: Options(
            headers: {
              'X-Content-Type-Options': 'nosniff',
            },
          ),
        )
            .timeout(
          Duration(seconds: 8),
          onTimeout: () {
            throw TimeoutException(context.tr('error_timeout'));
          },
        );
        final dataJson = response.data;
        final key = dataJson['key'];
        userKey = key;
        await storage.write(key: 'user', value: key);
      } else {
        userKey = await storage.read(key: 'user') ?? '';
      }

      final response = await Dio()
          .get(
        "https://$domainName/api/firebase/init/data/$userKey",
        options: Options(
          headers: {
            'X-Content-Type-Options': 'nosniff',
          },
        ),
      )
          .timeout(
        Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException(context.tr('error_timeout'));
        },
      );
      if (response.data['status'] == true) {
        final dataJson = response.data;
        final secureData = dataJson['data']['secure'];
        final x1 = dataJson['data']['x1'];
        final x2 = dataJson['data']['x2'];
        final version = dataJson['version'];
        final updateUrl = dataJson['updated_url'];

        final serverEncode = decrypt(secureData, x1, x2, userKey);

        List<String> servers = LineSplitter.split(serverEncode).toList();

        if (version == versionName) {
          await connect(servers);
        } else {
          if (updateUrl.isNotEmpty) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              title: context.tr('update_title'),
              desc: context.tr('update_description'),
              dialogBackgroundColor: Colors.white,
              btnCancelOnPress: () {},
              btnOkOnPress: () async {
                await launchUrl(Uri.parse(utf8.decode(base64Decode(updateUrl))),
                    mode: LaunchMode.externalApplication);
              },
              btnOkText: context.tr('download'),
              btnCancelText: context.tr('close'),
              buttonsTextStyle: TextStyle(
                  fontFamily: 'sm', color: Colors.white, fontSize: 14),
              titleTextStyle: TextStyle(
                  fontFamily: 'sb', color: Colors.black, fontSize: 16),
              descTextStyle: TextStyle(
                  fontFamily: 'sm', color: Colors.black, fontSize: 14),
            )..show();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr('update_install'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr('request_limit'),
                style: TextStyle(
                  fontFamily: 'GM',
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message!,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_get_version'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> connect(List<String> serverList) async {
    // حالت تست - فقط نمایش UI
    if (AppConfig.isTestMode) {
      setState(() {
        isLoading = true;
      });
      
      // شبیه‌سازی اتصال
      await Future.delayed(Duration(seconds: 2));
      
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TEST MODE: VPN disabled on emulator'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    if (serverList.isEmpty) {
      // سرور یافت نشد
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_no_server_connected'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> list = [];

    serverList.forEach((element) {
      final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(element);

      list.add(v2rayURL.getFullConfiguration());
    });

    Map<String, dynamic> getAllDelay =
        jsonDecode(await flutterV2ray.getAllServerDelay(configs: list));

    list.clear();

    int minPing = 99999999;
    String bestConfig = '';

    getAllDelay.forEach(
      (key, value) {
        if (value < minPing && value != -1) {
          setState(() {
            bestConfig = key;
            minPing = value;
          });
        }
      },
    );

    if (bestConfig.isNotEmpty) {
      if (await flutterV2ray.requestPermission()) {
        flutterV2ray.startV2Ray(
          remark: context.tr('app_title'),
          config: bestConfig,
          proxyOnly: false,
          bypassSubnets: null,
          notificationDisconnectButtonName: context.tr('disconnect_btn'),
          blockedApps: blockedApps,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('error_permission')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('error_no_server_connected'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    Future.delayed(
      Duration(seconds: 1),
      () {
        delay();
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  void delay() async {
    if (v2rayStatus.value.state == 'CONNECTED') {
      connectedServerDelay = await flutterV2ray.getConnectedServerDelay();
      setState(() {
        isFetchingPing = true;
      });
    }
    if (!mounted) return;
  }
}
