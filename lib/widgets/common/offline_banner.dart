import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline =
            snapshot.data?.any((r) => r != ConnectivityResult.none) ?? true;

        if (isOnline) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.wrongRed.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.wrongRed.withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.wifi_off, color: AppTheme.wrongRed, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You are offline — using cached data',
                  style: TextStyle(color: AppTheme.wrongRed, fontSize: 13),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.3);
      },
    );
  }
}
