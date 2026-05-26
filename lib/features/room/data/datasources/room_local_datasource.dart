import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room_model.dart';

abstract class RoomLocalDatasource {
  Future<List<RoomModel>> getRooms();
  Future<void> saveRooms(List<RoomModel> rooms);
}

class RoomLocalDatasourceImpl implements RoomLocalDatasource {
  static const String _key = 'saved_rooms';

  @override
  Future<List<RoomModel>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => RoomModel.fromJson(e)).toList();
      } catch (e) {
        // ignore: avoid_print
        print('Error decoding rooms: \$e');
        return [];
      }
    } else {
      // Default initial rooms if none are saved
      return [
        RoomModel(id: 'r1', name: 'Living Room', deviceCount: 3, isActive: true, iconPath: 'assets/icons/living_room.png'),
        RoomModel(id: 'r2', name: 'Bedroom',  deviceCount: 2, isActive: false, iconPath: 'assets/icons/bedroom.png'),
      ];
    }
  }

  @override
  Future<void> saveRooms(List<RoomModel> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(rooms.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
