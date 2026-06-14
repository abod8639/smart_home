import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';

import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/presentation/widgets/room_management_dialogs.dart';

/// A widget that displays a list of rooms, either horizontally (compact) or vertically.
class RoomsListWidget extends ConsumerWidget {
  /// Whether the widget should display in a compact horizontal layout.
  final bool isCompact;

  /// Creates a [RoomsListWidget].
  const RoomsListWidget({
    this.isCompact = false,
    super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Responsive.isMobile(context) || isCompact) {
      return _buildMobileHorizontalList(context, ref);
    }

    final cardWidth = Responsive.isDesktop(context) ? double.infinity : null;
    final cardHeight = Responsive.isDesktop(context) ? double.infinity : 415.0;

    final dashboardState = ref.watch(dashboardControllerProvider);

    return ShadowContainer(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: dashboardState.rooms.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final room = dashboardState.rooms[index];
                    return _buildRoomTile(context, ref, room);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHorizontalList(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final roomsList = dashboardState.rooms;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: roomsList.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == roomsList.length) {
                  return GestureDetector(
                    onTap: () => RoomManagementDialogs.showAddRoomDialog(context, ref),
                    child: _buildMobileAddRoomCard(context),
                  );
                }
                final room = roomsList[index];
                return _buildMobileRoomCard(context, ref, room);
              },
            ),
        ),
      ],
    );
  }

  Widget _buildMobileRoomCard(BuildContext context, WidgetRef ref, RoomEntity room) {
    final isActive = room.isActive;
    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? (isCompact ? 125.0 : 140.0) : (isCompact ? 135.0 : 150.0);
    final double cardHeight = isMobile ? (isCompact ? 95.0 : 110.0) : (isCompact ? 105.0 : 120.0);
    final double cardPadding = isMobile ? (isCompact ? 10.0 : 12.0) : (isCompact ? 12.0 : 16.0);
    final double iconSize = isMobile ? (isCompact ? 14.0 : 16.0) : (isCompact ? 16.0 : 20.0);
    final double iconPadding = isMobile ? (isCompact ? 4.0 : 6.0) : (isCompact ? 6.0 : 8.0);
    final double titleFontSize = isMobile ? (isCompact ? 12.0 : 13.0) : (isCompact ? 13.0 : 15.0);
    final double subtitleFontSize = isMobile ? (isCompact ? 9.0 : 10.0) : (isCompact ? 10.0 : 11.0);

    final dashboardState = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    return GestureDetector(
      onTap: () => controller.selectRoom(room.id),
      onLongPress: () {
        controller.closeAllDevicesInRoom(room.id);
      },
      // RoomManagementDialogs.showRoomOptions(context, room),
      child: Container(
        height: cardHeight,
        width: cardWidth,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : AppTheme.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoomIcon(room.name),
                    color: isActive ? Colors.white : AppTheme.textGrey,
                    size: iconSize,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isActive ? Colors.white70 : Colors.transparent,
                  size: isCompact ? 14 : 16,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dashboardState.devices.where((d) => d.roomId == room.id || (d.roomId == null && room.id == "3")).length} devices',
                  style: TextStyle(
                    color: isActive ? Colors.white70 : AppTheme.textGrey,
                    fontSize: subtitleFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAddRoomCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? (isCompact ? 125.0 : 140.0) : (isCompact ? 135.0 : 150.0);
    final double cardHeight = isMobile ? (isCompact ? 95.0 : 110.0) : (isCompact ? 105.0 : 120.0);
    final double iconSize = isMobile ? (isCompact ? 18.0 : 22.0) : (isCompact ? 22.0 : 26.0);
    final double fontSize = isMobile ? (isCompact ? 10.0 : 11.0) : (isCompact ? 11.0 : 13.0);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.primaryBlue,
              size: iconSize,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Room',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, WidgetRef ref, RoomEntity room) {
    final isActive = room.isActive;
    final dashboardState = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    
    return GestureDetector(
      onTap: () => controller.selectRoom(room.id),
      onLongPress: () => RoomManagementDialogs.showRoomOptions(context, ref, room),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : AppTheme.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getRoomIcon(room.name),
              color: isActive ? Colors.white : AppTheme.textGrey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${dashboardState.devices.where((d) => d.roomId == room.id || (d.roomId == null && room.id == "3")).length} device(s)',
                    style: TextStyle(
                      color: isActive ? Colors.white70 : AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isActive ? Colors.white : AppTheme.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoomIcon(String name) {
    switch (name.toLowerCase()) {
      case 'bedroom':
        return Icons.bed_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'living room':
        return Icons.chair_outlined;
      case 'bathroom':
        return Icons.bathtub_outlined;
      default:
        return Icons.room_preferences_outlined;
    }
  }

}
