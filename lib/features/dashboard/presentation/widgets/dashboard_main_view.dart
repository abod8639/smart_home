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

class DashboardMainView extends ConsumerStatefulWidget {
  const DashboardMainView({super.key});

  @override
  ConsumerState<DashboardMainView> createState() => _DashboardMainViewState();
}

class _DashboardMainViewState extends ConsumerState<DashboardMainView> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    final gap = Responsive.contentGap(context);
    final deviceHeight = Responsive.deviceCardsHeight(context);
    final roomsListWidth = Responsive.deviceCardsWidth(context);
    final padding = Responsive.pagePadding(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // mobile view with better spacing
        if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
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
        final double rowHeight;
        if (_isFullscreen) {
          final viewportHeight = MediaQuery.sizeOf(context).height;
          rowHeight = viewportHeight - (padding * 2);
        } else {
          final previewWidth = constraints.maxWidth - 320 - gap - (padding * 2);
          final previewHeight = previewWidth * 8.5 / 16;
          // Clamp height to a minimum of 400.0 to ensure room list has sufficient space
          rowHeight = previewHeight < 400.0 ? 400.0 : previewHeight;
        }

        return SingleChildScrollView(
          physics: _isFullscreen ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  height: rowHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            const RoomPreviewWidget(),
                            Positioned(
                              bottom: 20,
                              right: 40,
                              child: FloatingActionButton(
                                tooltip: _isFullscreen ? "Exit Full Screen" : "Full Screen",
                                backgroundColor: Colors.amberAccent,
                                foregroundColor: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    _isFullscreen = !_isFullscreen;
                                  });
                                },
                                child: Icon(
                                  size: 30,
                                  _isFullscreen
                                      ? Icons.close_fullscreen_sharp
                                      : Icons.open_in_full_sharp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        width: _isFullscreen ? 0 : gap,
                      ),
              
                      // Right Column: Live Weather + Rooms List
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        width: _isFullscreen ? 0 : roomsListWidth,
                        child: ClipRect(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              width: roomsListWidth,
                              child: AnimatedOpacity(
                                opacity: _isFullscreen ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  height: _isFullscreen ? 0 : (deviceHeight + gap * 2.5 + 45),
                  child: ClipRect(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: deviceHeight + gap * 2.5 + 45,
                        child: AnimatedOpacity(
                          opacity: _isFullscreen ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: gap),
                              Text(
                                'Devices',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: gap * 0.5),
                              SizedBox(height: deviceHeight-10, child: buildDeviceCards(ref, context)),
                              SizedBox(height: gap),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
