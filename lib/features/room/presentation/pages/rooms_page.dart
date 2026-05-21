import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {'name': 'Living Room', 'icon': Icons.weekend},
      {'name': 'Bedroom', 'icon': Icons.bed},
      {'name': 'Kitchen', 'icon': Icons.kitchen},
      {'name': 'Office', 'icon': Icons.computer},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('My Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.neonBlue),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
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
        child: Padding(
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
                  // Navigate to devices page, passing the room name
                  context.push('/devices', extra: room['name']);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      room['icon'] as IconData,
                      size: 48,
                      color: AppTheme.neonBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      room['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
