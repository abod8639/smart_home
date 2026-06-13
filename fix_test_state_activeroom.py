with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

c = c.replace('container.read(dashboardControllerProvider).activeRoom', 'container.read(dashboardControllerProvider.notifier).activeRoom')

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)
