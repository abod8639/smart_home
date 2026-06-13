import re

path = 'test/dashboard_controller_test.dart'
with open(path, 'r') as f:
    c = f.read()

# Replace the exact sequence that causes duplicates
pattern = r"        final container = createContainer\(\);\n        final controller = container\.read\(dashboardControllerProvider\.notifier\);\n\s*(final mockFirebase =)"
c = re.sub(pattern, r"        \1", c)

with open(path, 'w') as f:
    f.write(c)
