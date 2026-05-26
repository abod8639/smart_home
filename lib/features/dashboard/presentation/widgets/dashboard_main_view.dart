import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/weather_update_widget.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/lamp_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/vacuum_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/door_card.dart';

class DashboardMainView extends GetView<DashboardController> {
  const DashboardMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Section: Room Preview, Weather Update & Rooms List
        const Expanded(
          child: Row(
            children: [
              RoomPreviewWidget(),
              SizedBox(width: 20),
              WeatherUpdateWidget(),
              SizedBox(width: 20),
              RoomsListWidget(),
            ],
          ),
        ),
        
        const SizedBox(height: 20),

        // Bottom Section: Device Cards
        SizedBox(
          height: 240,
          child: Obx(() {
            if (controller.devices.isEmpty) return const SizedBox.shrink();

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.devices.length,
              separatorBuilder: (context, index) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final device = controller.devices[index];
                
                switch (device.type) {
                  case DeviceType.airConditioner:
                    return AcCard(
                      device: device,
                      onToggle: () => controller.toggleDevice(device.id),
                    );
                  case DeviceType.lamp:
                    return LampCard(
                      device: device,
                      onToggle: () => controller.toggleDevice(device.id),
                    );
                  case DeviceType.vacuum:
                    return VacuumCard(
                      device: device,
                      onToggle: () => controller.toggleDevice(device.id),
                    );
                  case DeviceType.door:
                    return DoorCard(
                      device: device,
                      onToggle: () => controller.toggleDoor(device.id),
                    );
                }
              },
            );
          }),
        ),
      ],
    );
  }
}
