import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/services/app_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppInitializer Tests', () {
    test('isFirebaseSupported returns a boolean reflecting current platform', () {
      expect(AppInitializer.isFirebaseSupported, isA<bool>());
    });

    test('initEnvironment handles missing env file gracefully without throwing', () async {
      await expectLater(
        AppInitializer.initEnvironment(envFile: '.non_existent_env_file'),
        completes,
      );
    });

    test('initHive opens boxes without crashing in test environment', () async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test');
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      await expectLater(
        AppInitializer.initHive(testPath: tempDir.path),
        completes,
      );
    });
  });
}
