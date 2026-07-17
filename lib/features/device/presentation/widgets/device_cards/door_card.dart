import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

/// A control card widget for managing and viewing status of a smart door lock.
class DoorCard extends StatelessWidget {
  /// The door device entity representation.
  final DeviceEntity device;
  /// Callback executed when toggling the lock state.
  final VoidCallback onToggle;
  /// When true, the toggle button shows a loading indicator and ignores taps.
  final bool isPending;

  /// Creates a constant [DoorCard] instance.
  const DoorCard({super.key, required this.device, required this.onToggle, this.isPending = false});

  @override
  Widget build(BuildContext context) {
    final isLocked = device.isLocked ?? true;
    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? 220.0 : 250.0;
    final double padding = isMobile ? 12.0 : 18.0;
    final double orbSize = isMobile ? 50.0 : 64.0;
    final double iconSize = isMobile ? 30.0 : 38.0;

    return SizedBox(
      width: cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title and badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${device.linkedDevicesCount} Devices Connected',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: isLocked ? Colors.redAccent : Colors.greenAccent,
                  size: isMobile ? 18 : 22,
                ),
              ],
            ),
            
            const Spacer(),
            
            // Lock State Visualizer
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: orbSize,
                height: orbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked 
                      ? Colors.redAccent.withValues(alpha: 0.1) 
                      : Colors.greenAccent.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isLocked 
                        ? Colors.redAccent.withValues(alpha: 0.3) 
                        : Colors.greenAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLocked 
                          ? Colors.redAccent.withValues(alpha: 0.15) 
                          : Colors.greenAccent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(
                  isLocked ? Icons.security : Icons.vpn_key,
                  color: isLocked ? Colors.redAccent : Colors.greenAccent,
                  size: iconSize,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Slider or Toggle Button
            GestureDetector(
              onTap: isPending ? null : onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isPending
                      ? LinearGradient(
                          colors: [const Color(0xFF78716C), const Color(0xFF57534E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : LinearGradient(
                          colors: isLocked
                              ? [Colors.redAccent, Colors.orangeAccent]
                              : [Colors.greenAccent, Colors.tealAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isPending
                          ? Colors.grey.withValues(alpha: 0.15)
                          : (isLocked ? Colors.redAccent : Colors.greenAccent).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Center(
                  child: isPending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        )
                      : Text(
                          isLocked ? 'TAP TO UNLOCK' : 'TAP TO LOCK',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 10 : 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
