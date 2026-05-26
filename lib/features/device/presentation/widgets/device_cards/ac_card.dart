import 'package:flutter/material.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AcCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const AcCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = device.isOn;

    return Expanded(
      flex: 3,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, Subtitle & Custom Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name, 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FULL HOUSE', 
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4), 
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Custom Switch matching the screenshot
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 52,
                    height: 28,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDeviceOn 
                          ? const Color(0xFF00E5FF) 
                          : const Color(0xFF334155),
                      boxShadow: isDeviceOn ? [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      alignment: isDeviceOn ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Middle Area: Custom Drawn AC Unit
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Temperature Badge (Top Left)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thermostat, 
                              color: isDeviceOn ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.4), 
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${device.temperature}°',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Central AC Unit & Breeze Visualizer
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          // AC Body Shape
                          Container(
                            width: 150,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDeviceOn 
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [const Color(0xFF1E293B), const Color(0xFF182235)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDeviceOn 
                                    ? Colors.white.withValues(alpha: 0.12) 
                                    : Colors.white.withValues(alpha: 0.05),
                                width: 1,
                              ),
                              boxShadow: isDeviceOn ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Air vent / LED slit inside AC body
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 130,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: isDeviceOn 
                                          ? const Color(0xFF00E5FF) 
                                          : const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(1.5),
                                      boxShadow: isDeviceOn ? [
                                        BoxShadow(
                                          color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                          blurRadius: 4,
                                          spreadRadius: 0.5,
                                        )
                                      ] : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Dynamic blowing air breeze below AC
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isDeviceOn ? 1.0 : 0.0,
                            child: Container(
                              width: 120,
                              height: 16,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Area: Mode & Live Running Time Stats
            Row(
              children: [
                Expanded(
                  child: _buildBottomStat(
                    device.mode == 'Eco mode' ? Icons.eco_outlined : Icons.wb_sunny_outlined, 
                    device.mode ?? 'Auto mode', 
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBottomStat(
                    Icons.access_time, 
                    _formatRunningTime(device.coolingTime), 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format running time from minutes to a readable string (e.g. 35 min or 1h 15m)
  String _formatRunningTime(int? totalMinutes) {
    if (totalMinutes == null || totalMinutes == 0) return '0 min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '$minutes min';
    }
  }

  Widget _buildBottomStat(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w400, 
                fontSize: 13,
              ), 
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
