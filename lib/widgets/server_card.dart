import 'package:flutter/material.dart';

class ServerCard extends StatelessWidget {
  final String countryName;
  final String countryCode;
  final String? flagEmoji;
  final int? ping;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const ServerCard({
    Key? key,
    required this.countryName,
    required this.countryCode,
    this.flagEmoji,
    this.ping,
    this.isSelected = false,
    this.isRecommended = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E40AF).withOpacity(0.2)
              : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flagEmoji ?? '🌍',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Country name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        countryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Best',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 12,
                        color: _getSignalColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ping != null ? '${ping}ms' : 'retry',
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
            
            // Connection icon
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3B82F6),
                size: 24,
              )
            else
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getSignalColor() {
    if (ping == null) return Colors.grey;
    if (ping! < 50) return const Color(0xFF10B981); // Green
    if (ping! < 100) return const Color(0xFFFBBF24); // Yellow
    return const Color(0xFFEF4444); // Red
  }
}
