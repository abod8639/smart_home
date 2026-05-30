import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';

import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

class RoomsListWidget extends GetView<DashboardController> {
  final bool isCompact;
  const RoomsListWidget({
    this.isCompact = false,
    super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context) || isCompact) {
      return _buildMobileHorizontalList(context);
    }

    final cardWidth = Responsive.isDesktop(context) ? double.infinity : null;
    final cardHeight = Responsive.isDesktop(context) ? double.infinity : 415.0;

    return ShadowContainer(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Rooms', style: Theme.of(context).textTheme.titleLarge),
          //     const Icon(Icons.info_outline, color: AppTheme.textGrey, size: 20),
          //   ],
          // ),
          // const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.rooms.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final room = controller.rooms[index];
                    return _buildRoomTile(context, room);
                  },
                )),
          ),
          // const SizedBox(height: 12),
          // GestureDetector(
          //   onTap: () => _showAddRoomDialog(context),
          //   child: _buildAddRoomButton(),
          // ),
        ],
      ),
    );
  }

  Widget _buildMobileHorizontalList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // const SizedBox(height: 12),
        Expanded(
          flex: 1,
          child: Obx(() {
            final roomsList = controller.rooms;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: roomsList.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == roomsList.length) {
                  return GestureDetector(
                    onTap: () => _showAddRoomDialog(context),
                    child: _buildMobileAddRoomCard(),
                  );
                }
                final room = roomsList[index];
                return _buildMobileRoomCard(context, room);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileRoomCard(BuildContext context, RoomEntity room) {
    final isActive = room.isActive;
    return GestureDetector(
      onTap: () => controller.selectRoom(room.id),
      onLongPress: () => _showRoomOptions(context, room),
      child: Container(
        height: 120,
        width: 150,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoomIcon(room.name),
                    color: isActive ? Colors.white : AppTheme.textGrey,
                    size: 20,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isActive ? Colors.white70 : Colors.transparent,
                  size: 16,
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
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${controller.devices.where((d) => d.roomId == room.id || (d.roomId == null && room.id == "3")).length} devices',
                  style: TextStyle(
                    color: isActive ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAddRoomCard() {
    return Container(
      width: 150,
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
              size: 26,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Room',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, RoomEntity room) {
    final isActive = room.isActive;
    return GestureDetector(
      onTap: () => controller.selectRoom(room.id),
      onLongPress: () => _showRoomOptions(context, room),
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
                    '${controller.devices.where((d) => d.roomId == room.id || (d.roomId == null && room.id == "3")).length} device(s)',
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

  void _showRoomOptions(BuildContext context, RoomEntity room) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Text(
            'Room Options: ${room.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                title: const Text('Edit Room Name', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditRoomDialog(context, room);
                },
              ),
              if (room.name.toLowerCase() != 'living room')
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Delete Room', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, room);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final textController = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Add New Room',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Room Name',
                      labelStyle: const TextStyle(color: AppTheme.textGrey),
                      hintText: 'e.g. Office, Bedroom',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Room Background Image / صورة خلفية الغرفة',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context, (path) {
                      setState(() {
                        selectedImagePath = path;
                      });
                    }),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedImagePath != null 
                              ? Colors.transparent 
                              : AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: selectedImagePath != null
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(selectedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImagePath = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                                  size: 32,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'اضغط لالتقاط أو اختيار صورة للغرفة\nTap to capture or select photo',
                                  style: TextStyle(
                                    color: AppTheme.textGrey.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  final newRoom = RoomEntity(
                    id: 'room_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    deviceCount: 0,
                    isActive: false,
                    imagePath: selectedImagePath,
                  );
                  controller.addRoom(newRoom);
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditRoomDialog(BuildContext context, RoomEntity room) {
    final textController = TextEditingController(text: room.name);
    String? selectedImagePath = room.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Edit Room',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Room Name',
                      labelStyle: const TextStyle(color: AppTheme.textGrey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Room Background Image / صورة خلفية الغرفة',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context, (path) {
                      setState(() {
                        selectedImagePath = path;
                      });
                    }),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedImagePath != null 
                              ? Colors.transparent 
                              : AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: selectedImagePath != null
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(selectedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImagePath = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                                  size: 32,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'اضغط لالتقاط أو اختيار صورة للغرفة\nTap to capture or select photo',
                                  style: TextStyle(
                                    color: AppTheme.textGrey.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  controller.updateRoom(room.copyWith(
                    name: name,
                    imagePath: selectedImagePath,
                  ));
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoomEntity room) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Delete Room',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${room.name}"? This action cannot be undone.',
            style: const TextStyle(color: AppTheme.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                controller.deleteRoom(room.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return pickedFile?.path;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  void _showImageSourceActionSheet(BuildContext context, Function(String) onImagePicked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر مصدر الصورة / Select Image Source',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryPurple),
                ),
                title: const Text('التقاط صورة للكاميرا / Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _pickImage(ImageSource.camera);
                  if (path != null) onImagePicked(path);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryBlue),
                ),
                title: const Text('اختيار من المعرض / Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _pickImage(ImageSource.gallery);
                  if (path != null) onImagePicked(path);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
