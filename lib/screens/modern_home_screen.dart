import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pingo/common/config.dart';
import 'package:pingo/widgets/modern_power_button.dart';
import 'package:pingo/widgets/server_card.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({Key? key}) : super(key: key);

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with SingleTickerProviderStateMixin {
  bool isConnected = false;
  bool isLoading = false;
  String selectedServer = 'Netherlands';
  String selectedFlag = '🇳🇱';
  int selectedTab = 0;
  
  late TabController _tabController;

  // Mock data - بعداً با داده واقعی جایگزین میشه
  final List<Map<String, dynamic>> recentServers = [
    {'name': 'Netherlands', 'flag': '🇳🇱', 'ping': 45},
    {'name': 'Germany', 'flag': '🇩🇪', 'ping': 52},
    {'name': 'Finland', 'flag': '🇫🇮', 'ping': 68},
  ];

  final List<Map<String, dynamic>> allServers = [
    {'name': 'Finland', 'flag': '🇫🇮', 'ping': 68, 'recommended': true},
    {'name': 'Netherlands', 'flag': '🇳🇱', 'ping': 45, 'recommended': false},
    {'name': 'Germany', 'flag': '🇩🇪', 'ping': 52, 'recommended': false},
    {'name': 'United States', 'flag': '🇺🇸', 'ping': 120, 'recommended': false},
    {'name': 'United Kingdom', 'flag': '🇬🇧', 'ping': 38, 'recommended': false},
    {'name': 'France', 'flag': '🇫🇷', 'ping': 42, 'recommended': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleConnect() {
    setState(() {
      isLoading = true;
    });

    // Simulate connection
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isConnected = !isConnected;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildConnectionStatus(),
            _buildPowerButton(),
            _buildCurrentServer(),
            const SizedBox(height: 24),
            _buildRecentlyConnected(),
            const SizedBox(height: 16),
            _buildServerTabs(),
            Expanded(child: _buildServerList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PINGO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isConnected ? 'is Connected' : 'is Disconnected',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: ModernPowerButton(
        isConnected: isConnected,
        isLoading: isLoading,
        onTap: _handleConnect,
        size: 140,
      ),
    );
  }

  Widget _buildCurrentServer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                selectedFlag,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedServer.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Vulnerable network • -----',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyConnected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'RECENTLY CONNECTED',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentServers.length,
            itemBuilder: (context, index) {
              final server = recentServers[index];
              return _buildRecentServerCard(
                server['name'],
                server['flag'],
                server['ping'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentServerCard(String name, String flag, int ping) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_cellular_alt,
                size: 10,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                'retry',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('All', 0),
          _buildTab('Unlimited', 1),
          _buildTab('Gaming', 2),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[400]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[400]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildServerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: allServers.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.rocket_launch,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Best Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final server = allServers[index - 1];
        return ServerCard(
          countryName: server['name'],
          countryCode: server['name'].substring(0, 2).toUpperCase(),
          flagEmoji: server['flag'],
          ping: server['ping'],
          isSelected: server['name'] == selectedServer,
          isRecommended: server['recommended'] ?? false,
          onTap: () {
            setState(() {
              selectedServer = server['name'];
              selectedFlag = server['flag'];
            });
          },
        );
      },
    );
  }
}
