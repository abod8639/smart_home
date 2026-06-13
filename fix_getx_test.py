import re

path = 'test/dashboard_controller_test.dart'
with open(path, 'r') as f:
    c = f.read()

# 1. Remove Get.reset() and Get.testMode
c = re.sub(r'^\s*Get\.reset\(\);\s*\n', '', c, flags=re.MULTILINE)
c = re.sub(r'^\s*Get\.testMode\s*=\s*true;\s*\n', '', c, flags=re.MULTILINE)

# 2. Find and replace `Get.put(DashboardController())`
# But only if it's not already preceded by container creation. Let's just replace it with:
# final container = createContainer();
# final controller = container.read(dashboardControllerProvider.notifier);
# Wait! If we replace it, we might shadow 'container' if mock setup follows.
# So let's look for block patterns.

# Often the pattern is:
# final controller = Get.put(DashboardController());
# Get.put<FirebaseService>(mockFirebase);
# ...
c = re.sub(r'final controller = Get\.put\(DashboardController\(\)\);', 'final container = createContainer();\n        final controller = container.read(dashboardControllerProvider.notifier);', c)

# 3. For any subsequent Get.put overrides in the same test, it's actually complicated.
# We'd have to group them into overrides. Let's just remove all `Get.put<...>` because they are useless now.
# Wait, if we remove them, how does the container get the mocks?
# The container created by `createContainer()` above DOES NOT HAVE THE MOCKS!
# If a test requires mocks, we MUST pass `overrides: [...]` to `createContainer()`.

