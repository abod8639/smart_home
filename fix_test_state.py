import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# Replace GetX .value accesses
c = re.sub(r'controller\.temperature\.value', 'container.read(dashboardControllerProvider).temperature', c)
c = re.sub(r'controller\.humidity\.value', 'container.read(dashboardControllerProvider).humidity', c)
c = re.sub(r'controller\.currentNavigationIndex\.value', 'container.read(dashboardControllerProvider).currentNavigationIndex', c)
c = re.sub(r'controller\.activeRoom', 'container.read(dashboardControllerProvider).activeRoom', c)
c = re.sub(r'controller\.devices', 'container.read(dashboardControllerProvider).devices', c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)

