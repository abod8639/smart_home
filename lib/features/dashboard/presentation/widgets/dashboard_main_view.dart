import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/weather_update_widget.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/lamp_card.dart';

class DashboardMainView extends GetView<DashboardController> {
  const DashboardMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Section: Room Preview, Weather Update & Rooms List
        const Expanded(
          flex: 8,
          child: Row(
            children: [
              RoomPreviewWidget(),
              SizedBox(width: 24),
              WeatherUpdateWidget(),
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

            final ac1 = controller.devices.firstWhereOrNull((d) => d.id == 'ac1');
            final ac2 = controller.devices.firstWhereOrNull((d) => d.id == 'ac2');
            final lamp = controller.devices.firstWhereOrNull((d) => d.id == 'lamp1');

            return Row(
              children: [
                if (ac1 != null) ...[
                  AcCard(
                    device: ac1,
                    onToggle: () => controller.toggleDevice(ac1.id),
                  ),
                  const SizedBox(width: 24),
                ],
                if (ac2 != null) ...[
                  AcCard(
                    device: ac2,
                    onToggle: () => controller.toggleDevice(ac2.id),
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
    );
  }
}
