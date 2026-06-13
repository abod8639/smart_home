import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/pages/remote_page.dart';
import 'package:smart_home/features/dashboard/presentation/pages/rgb_page.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/room_preview_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/weather_update_widget.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/lamp_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/vacuum_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/door_card.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/rgb_card.dart';

class DashboardMainView extends ConsumerWidget {
  const DashboardMainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gap = Responsive.contentGap(context);
    final deviceHeight = Responsive.deviceCardsHeight(context);
    final padding = Responsive.pagePadding(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // mobile view with better spacing
        if (Responsive.isMobile(context)||Responsive.isTablet(context)) {
          // Mobile Layout: One single vertical scrollable Column to avoid layout issues
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  SizedBox(height: deviceHeight, child: buildDeviceCards(ref, context)),
                  SizedBox(height: gap),
                  Text(
                    'Rooms',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: gap * 0.5),
                  const SizedBox(height: 140, child: RoomsListWidget()),
                  SizedBox(
                    height: gap * 2,
                  ), // spacing at bottom for navbar clearance
                ],
              ),
            ),
          );
        }

        // Desktop / Wide Layout (width >= 950): 2-Column Layout
        final previewWidth = constraints.maxWidth - 320 - gap - (padding * 2);
        final previewHeight = previewWidth * 8.5 / 16;
        // Clamp height to a minimum of 400.0 to ensure room list has sufficient space
        final rowHeight = previewHeight < 400.0 ? 400.0 : previewHeight;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: rowHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: RoomPreviewWidget(),
                      ),
                      SizedBox(width: gap),
              
                      // Right Column: Live Weather + Rooms List
                      SizedBox(
                        width: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const WeatherUpdateWidget(),
                            SizedBox(height: gap),
                            Text(
                              'Rooms',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: gap),
                            const Expanded(
                              child: RoomsListWidget(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: gap),
                Text(
                  'Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: gap * 0.5),
            
                SizedBox(height: deviceHeight, child: buildDeviceCards(ref, context)),
                SizedBox(height: gap),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget buildDeviceCards(WidgetRef ref, BuildContext context) {
  final dashboardState = ref.watch(dashboardControllerProvider);
  final dashboardController = ref.read(dashboardControllerProvider.notifier);
  
  final activeRoomId = dashboardController.activeRoom?.id ?? '3';
  final filteredDevices = dashboardState.devices
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
        SizedBox(
          // height: 10,
          width: Responsive.contentGap(context)),
    itemBuilder: (context, index) {
      final device = filteredDevices[index];

      switch (device.type) {
        case DeviceType.airConditioner:
          return GestureDetector(
            onLongPress: (){
              // go to remote page using Navigator push
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RemotePage(device: device))
              );
            },
            child: AcCard(
              onDecreaseTemp: () {
                dashboardController.updateAcTemperature(
                  device.id,
                  (device.temperature ?? 24) - 1,
                );
              },
              device: device,
              onIncreaseTemp: () {
                dashboardController.updateAcTemperature(
                  device.id,
                  (device.temperature ?? 24) + 1,
                );
              },
              onToggle: () => dashboardController.toggleDevice(device.id),
              onModeChange: (mode) =>
                  dashboardController.setAcMode(context, device.id, mode),
            ),
          );
        case DeviceType.lamp:
          return LampCard(
            device: device,
            onToggle: () => dashboardController.toggleDevice(device.id),
          );
        case DeviceType.vacuum:
          return VacuumCard(
            device: device,
            onToggle: () => dashboardController.toggleDevice(device.id),
          );
        case DeviceType.door:
          return DoorCard(
            device: device,
            onToggle: () => dashboardController.toggleDoor(device.id),
          );
        case DeviceType.rgb:
          return GestureDetector(
            onLongPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RgbPage(device: device))
              );
            },
            child: RgbCard(
              device: device,
              onToggle: () => dashboardController.toggleDevice(device.id),
            ),
          );
      }
    },
  );
}
