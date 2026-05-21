import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/room_entity.dart';
import '../providers/room_providers.dart';

class AddRoomDialog extends ConsumerStatefulWidget {
  const AddRoomDialog({super.key});

  @override
  ConsumerState<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<AddRoomDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedIconCode = Icons.meeting_room.codePoint;

  final List<IconData> _availableIcons = [
    Icons.meeting_room,
    Icons.weekend,
    Icons.bed,
    Icons.kitchen,
    Icons.computer,
    Icons.bathroom,
    Icons.garage,
    Icons.balcony,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addRoom() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newRoom = RoomEntity(
      id: const Uuid().v4(),
      name: name,
      iconCode: _selectedIconCode,
    );

    ref.read(roomControllerProvider.notifier).addRoom(newRoom);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEW SECTOR', // Cyberpunk wording
              style: TextStyle(
                color: AppTheme.neonCyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Sector Name (e.g. Lab, Armory)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SELECT ICON',
              style: TextStyle(
                color: AppTheme.neonPink,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIconCode == icon.codePoint;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconCode = icon.codePoint;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.neonPink.withValues(alpha: 0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppTheme.neonPink : Colors.white24,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.neonPink.withValues(alpha: 0.5),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.2),
                  foregroundColor: AppTheme.neonCyan,
                  side: const BorderSide(color: AppTheme.neonCyan),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _addRoom,
                child: const Text(
                  'INITIALIZE',
                  style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
