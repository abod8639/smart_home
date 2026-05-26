import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class RoomPreviewWidget extends GetView<DashboardController> {
  const RoomPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
            image: AssetImage('assets/images/living_room.png'),
            fit: BoxFit.fill,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          children: [
            // Top overlay gradient for text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Live indicator
                  // GlassContainer(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   borderRadius: BorderRadius.circular(20),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Container(
                  //         width: 8,
                  //         height: 8,
                  //         decoration: const BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: Colors.redAccent,
                  //         ),
                  //       ),
                  //       const SizedBox(width: 8),
                  //       const Text('Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  //     ],
                  //   ),
                  // ),
                  
                  // Environment Stats
                  Obx(() => Row(
                    children: [
                      _buildStatChip(Icons.water_drop_outlined, controller.humidity.value),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.air_outlined, controller.airflow.value),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.thermostat_outlined, controller.temperature.value),
                      // const SizedBox(width: 12),
                      // _buildStatChip(Icons.electric_bolt_outlined, controller.powerUsage.value),
                    ],
                  )),
                ],
              ),
            ),

            // Mock Device Markers (Simulated AR)
            Positioned(
              top: 150,
              left: 200,
              child: _buildDeviceMarker('3 Device'),
            ),
            Positioned(
              top: 250,
              left: 300,
              child: _buildDeviceMarker('2 Device'),
            ),

            // Smart Door Widget Overlay
            // Positioned(
            //   bottom: 24,
            //   right: 24,
            //   child: _buildSmartDoorWidget(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDeviceMarker(String text) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 5,
              )
            ],
          ),
        ),
        const SizedBox(height: 4),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(12),
          borderGradient: false,
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }

  // Widget _buildSmartDoorWidget() {
  //   return Obx(() {
  //     final doorDevice = controller.devices.firstWhereOrNull((d) => d.id == 'door1');
  //     final isLocked = doorDevice?.isLocked ?? true;
      
  //     return GlassContainer(
  //       width: 250,
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withValues(alpha: 0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Icon(
  //                   isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
  //                   color: isLocked ? AppTheme.accentCyan : Colors.greenAccent,
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text('Smart Door', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
  //                   Text(isLocked ? 'Locked' : 'Unlocked', style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           // Mock Slide to unlock
  //           Container(
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.black.withValues(alpha: 0.5),
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Row(
  //               children: [
  //                 GestureDetector(
  //                   onTap: () => controller.toggleDoor('door1'),
  //                   child: Container(
  //                     width: 40,
  //                     height: 40,
  //                     decoration: const BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Colors.orangeAccent,
  //                     ),
  //                     child: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
  //                   ),
  //                 ),
  //                 const Expanded(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(Icons.chevron_right, color: Colors.white54, size: 16),
  //                       Icon(Icons.chevron_right, color: Colors.white54, size: 16),
  //                       Icon(Icons.chevron_right, color: Colors.white54, size: 16),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   width: 40,
  //                   height: 40,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     border: Border.all(color: Colors.greenAccent),
  //                   ),
  //                   child: const Icon(Icons.center_focus_strong_outlined, color: Colors.greenAccent, size: 20),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }



}
