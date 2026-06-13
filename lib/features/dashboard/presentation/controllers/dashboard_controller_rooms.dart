// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of 'dashboard_controller.dart';

// ==========================================
// Room Management Logic
// ==========================================


extension DashboardControllerRooms on DashboardController {
  void selectRoom(String id) {
    state = state.copyWith(
      rooms: state.rooms.map((r) => r.copyWith(isActive: r.id == id)).toList()
    );
    _persistRooms();
    
    // Attempt to clear selected device if RoomPlacementController is loaded
    try {
      ref.read(roomPlacementControllerProvider.notifier).selectDevice(null);
    } catch (_) {
      // Ignore if provider doesn't exist yet
    }
  }

  void addRoom(RoomEntity room) {
    state = state.copyWith(rooms: [...state.rooms, room]);
    _persistRooms();
  }

  void updateRoom(RoomEntity room) {
    final index = state.rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      final newRooms = List<RoomEntity>.from(state.rooms);
      newRooms[index] = room;
      state = state.copyWith(rooms: newRooms);
      _persistRooms();
    }
  }

  void deleteRoom(String id) {
    final newRooms = state.rooms.where((r) => r.id != id).toList();
    // If the active room is deleted, select the first remaining room
    final hasActive = newRooms.any((r) => r.isActive);
    if (!hasActive && newRooms.isNotEmpty) {
      newRooms[0] = newRooms[0].copyWith(isActive: true);
    }
    state = state.copyWith(rooms: newRooms);
    _persistRooms();
  }
}
