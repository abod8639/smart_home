import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/profile_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/preferences_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/google_home_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/hub_config_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/device_placement_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/fcm_token_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/matter_code_card.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final gap = Responsive.contentGap(context);
    final isCompact = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isCompact),
          SizedBox(height: gap),
          Expanded(
            child: 
            Responsive.isTablet(context) || Responsive.isMobile(context)
                ? _buildMobileLayout(gap)
                :
                 _buildWideLayout(context, gap),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isCompact ? 24 : 28,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Configure your smart home network & preferences',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
        ),
      ],
    );

    final statusBadge = Consumer(builder: (context, ref, _) {
      final isHubReachable = ref.watch(settingsControllerProvider.select((s) => s.isHubReachable));
      final color = isHubReachable ? Colors.greenAccent : Colors.redAccent;
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isHubReachable ? Icons.wifi : Icons.wifi_off, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              isHubReachable ? 'Hub Connected' : 'Hub Offline',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 12),
          statusBadge,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [titleSection, statusBadge],
    );
  }

  Widget _buildMobileLayout(double gap) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const ProfileCard(),
          SizedBox(height: gap),
          const PreferencesCard(),
          SizedBox(height: gap),
          const GoogleHomeCard(),
          SizedBox(height: gap),
          const FcmTokenCard(),
          SizedBox(height: gap),
          SizedBox(height: 320, child: DevicePlacementCard()),
          SizedBox(height: gap),
          const HubConfigCard(),
          SizedBox(height: gap),
          const MatterCodeCard(),
          SizedBox(height: gap),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, double gap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: Responsive.isTablet(context) ? 5 : 4,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ProfileCard(),
                SizedBox(height: gap),
                const PreferencesCard(),
                SizedBox(height: gap),
                const GoogleHomeCard(),
                SizedBox(height: gap),
                const FcmTokenCard(),
              ],
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: Responsive.isTablet(context) ? 5 : 5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const HubConfigCard(),
                SizedBox(height: gap),
                const MatterCodeCard(),
                SizedBox(height: gap),
                SizedBox(
                  height: Responsive.isTablet(context) ? 280 : 320,
                  child: DevicePlacementCard(),
                ),
                SizedBox(height: gap),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
