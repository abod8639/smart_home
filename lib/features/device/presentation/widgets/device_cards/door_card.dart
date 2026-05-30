import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class DoorCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const DoorCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isLocked = device.isLocked ?? true;

    return SizedBox(
      width: 280,
      child: GlassContainer(
        padding: const EdgeInsets.all(15),
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
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${device.linkedDevicesCount} Devices Connected',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: isLocked ? Colors.redAccent : Colors.greenAccent,
                ),
              ],
            ),
            
            // const Spacer(),
            
            // Lock State Visualizer (Premium Custom Paint or Stack)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 60,
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
                          ? Colors.redAccent.withValues(alpha: 0.2) 
                          : Colors.greenAccent.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  isLocked ? Icons.security : Icons.vpn_key,
                  color: isLocked ? Colors.redAccent : Colors.greenAccent,
                  size: 40,
                ),
              ),
            ),
            
            const Spacer(),
            const Spacer(),
            const Spacer(),
            
            // Slider or Toggle Button
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLocked
                        ? [Colors.redAccent, Colors.orangeAccent]
                        : [Colors.greenAccent, Colors.tealAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isLocked ? Colors.redAccent : Colors.greenAccent).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    isLocked ? 'TAP TO UNLOCK' : 'TAP TO LOCK',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
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
