part of 'dashboard_controller.dart';

// ==========================================
// Room Management Logic
// ==========================================


extension DashboardControllerRooms on DashboardController {
  void selectRoom(String id) {
    rooms.value = rooms.map((r) => r.copyWith(isActive: r.id == id)).toList();
    _persistRooms();
    if (Get.isRegistered<RoomPlacementController>()) {
      Get.find<RoomPlacementController>().selectDevice(null);
    }
  }

  void addRoom(RoomEntity room) {
    rooms.add(room);
    _persistRooms();
  }

  void updateRoom(RoomEntity room) {
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room;
      _persistRooms();
    }
  }

  void deleteRoom(String id) {
    rooms.removeWhere((r) => r.id == id);
    // If the active room is deleted, select the first remaining room
    final hasActive = rooms.any((r) => r.isActive);
    if (!hasActive && rooms.isNotEmpty) {
      rooms[0] = rooms[0].copyWith(isActive: true);
    }
    _persistRooms();
  }
}
