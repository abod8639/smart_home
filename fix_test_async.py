import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# Make sure all test() callbacks are async
c = re.sub(r"test\('(.*?)', \(\) \{", r"test('\1', () async {", c)

# Add await Future.microtask(() {}); after controller is read
c = re.sub(r"(final controller = container\.read\(dashboardControllerProvider\.notifier\);)", r"\1\n          await Future.microtask(() {});", c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)

