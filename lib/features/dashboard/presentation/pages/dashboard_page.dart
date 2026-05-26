import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/sidebar_widget.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/sidebar_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/vacuum_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/lamp_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // 1. Sidebar Navigation
              const SidebarWidget(),

              // 2. Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Section: Room Preview & Rooms List
                    const Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          RoomPreviewWidget(),
                          SizedBox(width: 24),
                          RoomsListWidget(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Bottom Section: Device Cards
                    Expanded(
                      flex: 4,
                      child: Obx(() {
                        if (controller.devices.isEmpty) return const SizedBox.shrink();

                        final vac = controller.devices.firstWhereOrNull((d) => d.id == 'vac1');
                        final ac = controller.devices.firstWhereOrNull((d) => d.id == 'ac1');
                        final lamp = controller.devices.firstWhereOrNull((d) => d.id == 'lamp1');

                        return Row(
                          children: [
                            if (vac != null) ...[
                              VacuumCard(
                                device: vac,
                                onToggle: () => controller.toggleDevice(vac.id),
                              ),
                              const SizedBox(width: 24),
                            ],
                            if (ac != null) ...[
                              AcCard(
                                device: ac,
                                onToggle: () => controller.toggleDevice(ac.id),
                              ),
                              const SizedBox(width: 24),
                            ],
                            if (lamp != null)
                              LampCard(
                                device: lamp,
                                onToggle: () => controller.toggleDevice(lamp.id),
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
