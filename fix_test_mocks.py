import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# For any test that defines mockFirebase AFTER createContainer(), we need to move it up and override.
# Let's find occurrences of:
# final container = createContainer();
# final controller = container.read(dashboardControllerProvider.notifier);
#   await Future.microtask(() {});
# final mockFirebase = MockFirebaseService();
# final mockMatter = MockMatterService();

pattern = r"(final container = createContainer\(\);\n\s*final controller = container\.read\(dashboardControllerProvider\.notifier\);\n\s*await Future\.microtask\(\(\) \{\}\);\n\s*final mockFirebase = MockFirebaseService\(\);\n\s*final mockMatter = MockMatterService\(\);)"
replacement = """final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});"""

c = re.sub(pattern, replacement, c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)

