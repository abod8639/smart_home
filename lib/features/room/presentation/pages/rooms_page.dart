import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/room_providers.dart';
import '../widgets/add_room_dialog.dart';

class RoomsPage extends ConsumerWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('My Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.neonCyan),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.2),
        foregroundColor: AppTheme.neonCyan,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.neonCyan, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddRoomDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundDark,
              Color(0xFF1A1D2D),
            ],
          ),
        ),
        child: roomsAsync.when(
          data: (rooms) {
            if (rooms.isEmpty) {
              return const Center(
                child: Text(
                  'No Sectors Initialize.\nAdd a new sector.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return GlassContainer(
                    onTap: () {
                      context.push('/devices', extra: room.name);
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                IconData(room.iconCode, fontFamily: 'MaterialIcons'),
                                size: 48,
                                color: AppTheme.neonCyan,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                room.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(roomControllerProvider.notifier).deleteRoom(room.id);
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.neonPink,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonCyan),
          ),
          error: (e, st) => Center(
            child: Text('Error loading sectors: \$e', style: const TextStyle(color: AppTheme.neonPink)),
          ),
        ),
      ),
    );
  }
}
