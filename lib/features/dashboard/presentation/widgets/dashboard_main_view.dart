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

    return LayoutBuilder(
      builder: (context, constraints) {

        if (Responsive.isMobile(context)) {
          // Mobile Layout: One single vertical scrollable Column to avoid layout issues
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RoomPreviewWidget(),
                SizedBox(height: gap),
                const WeatherUpdateWidget(),
                SizedBox(height: gap),
                Text(
                  'Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: gap * 0.5),
                SizedBox(
                  height: deviceHeight,
                  child: buildDeviceCards(),
                ),
                SizedBox(height: gap),
                Text(
                  'Rooms',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: gap * 0.5),
                const SizedBox(
                  height: 140,
                  child: RoomsListWidget(),
                ),
                SizedBox(height: gap * 2), // spacing at bottom for navbar clearance
              ],
            ),
          );
        }

        if (Responsive.isTablet(context)) {
          // Tablet / Medium Layout: Scrollable Column with side-by-side preview and weather
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: Room Preview & Weather side-by-side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 5,
                      child: RoomPreviewWidget(),
                    ),
                    // SizedBox(width: gap),
                    // const SizedBox(
                    //   width: 280,
                    //   child: WeatherUpdateWidget(),
                    // ),
                  ],
                ),
                SizedBox(height: gap),

                // Rooms section
                Text(
                  'Rooms',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: gap * 0.5),
                const SizedBox(
                  height: 130, // Fits the horizontal room card height
                  child: RoomsListWidget(isCompact: true),
                ),
                SizedBox(height: gap),

                // Devices section
                Text(
                  'Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: gap * 0.5),
                SizedBox(
                  height: deviceHeight,
                  child: buildDeviceCards(),
                ),
                SizedBox(height: gap * 2),
              ],
            ),
          );
        }

        // Desktop / Wide Layout (width >= 950): 2-Column Layout
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Room Preview + Room Devices
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RoomPreviewWidget(),
                    SizedBox(height: gap),
                    Text(
                      'Devices',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: gap * 0.5),
                    SizedBox(
                      height: deviceHeight,
                      child: buildDeviceCards(),
                    ),
                    SizedBox(height: gap * 2),
                  ],
                ),
              ),
            ),
            SizedBox(width: gap),
            // Right Column: Live Weather + Rooms List
            SizedBox(
              width: 320,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WeatherUpdateWidget(),
                    SizedBox(height: gap),
                    Text(
                      'Rooms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: gap * 0.5),
                    const RoomsListWidget(),
                    SizedBox(height: gap * 2),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget buildDeviceCards() {
  final DashboardController controller = Get.find();
  return Obx(() {
    final activeRoomId = controller.activeRoom?.id ?? '3';
    final filteredDevices = controller.devices
        .where(
          (d) =>
              d.roomId == activeRoomId ||
              (d.roomId == null && activeRoomId == '3'),
        )
        .toList();

    if (filteredDevices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No devices in this room',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: filteredDevices.length,
      separatorBuilder: (context, index) =>
          SizedBox(width: Responsive.contentGap(context)),
      itemBuilder: (context, index) {
        final device = filteredDevices[index];

        switch (device.type) {
          case DeviceType.airConditioner:
            return AcCard(
              onDecreaseTemp: () {
                            Get.find<DashboardController>().updateAcTemperature(
                              device.id,
                              (device.temperature ?? 24) - 1,
                            );
                          },
              device: device,
              onIncreaseTemp: () {
                            Get.find<DashboardController>().updateAcTemperature(
                              device.id,
                              (device.temperature ?? 24) + 1,
                            );
                          },
              onToggle: () => controller.toggleDevice(device.id),
              onModeChange: (mode) =>
                  Get.find<DashboardController>().setAcMode(device.id, mode),
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
