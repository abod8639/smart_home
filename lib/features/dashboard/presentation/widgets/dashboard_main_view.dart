import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/weather_update_widget.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/lamp_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/vacuum_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/door_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/rgb_card.dart';

class DashboardMainView extends GetView<DashboardController> {
  const DashboardMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = Responsive.contentGap(context);
    final deviceHeight = Responsive.deviceCardsHeight(context);

    return Column(
      children: [
        Expanded(child: _buildTopSection(context, gap)),
        SizedBox(height: gap),
       if (!Responsive.isMobile(context)) SizedBox(height: deviceHeight, child: _buildDeviceCards()),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context, double gap) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          const Expanded(flex: 4, child: RoomPreviewWidget()),
          SizedBox(height: gap),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const WeatherUpdateWidget(),
                  SizedBox(height: gap),
                  SizedBox(height: 180, child: const RoomsListWidget()),
                  SizedBox(height: gap),
                  SizedBox(height: 180, child: _buildDeviceCards()),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (Responsive.isTablet(context)) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const RoomPreviewWidget(),
            SizedBox(height: gap),
            const WeatherUpdateWidget(),
            SizedBox(height: gap),
            const RoomsListWidget(),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: RoomPreviewWidget()),
        // SizedBox(width: gap),
        SizedBox(
          width: 280,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const WeatherUpdateWidget(),
                SizedBox(height: gap),
                const RoomsListWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCards() {
    return Obx(() {
      if (controller.devices.isEmpty) return const SizedBox.shrink();

      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.devices.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: Responsive.contentGap(context)),
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
            case DeviceType.rgb:
              return RgbCard(
                device: device,
                onToggle: () => controller.toggleDevice(device.id),
              );
          }
        },
      );
    });
  }
}
