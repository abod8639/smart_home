import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

c = re.sub(r'controller\.rooms', 'container.read(dashboardControllerProvider).rooms', c)
c = re.sub(r'controller\.devices', 'container.read(dashboardControllerProvider).devices', c)
c = re.sub(r'controller\.isWeatherLoading\.value', 'container.read(dashboardControllerProvider).isWeatherLoading', c)
c = re.sub(r'controller\.weatherLocation\.value', 'container.read(dashboardControllerProvider).weatherLocation', c)
c = re.sub(r'controller\.weatherTemp\.value', 'container.read(dashboardControllerProvider).weatherTemp', c)
c = re.sub(r'controller\.weatherCondition\.value', 'container.read(dashboardControllerProvider).weatherCondition', c)
c = re.sub(r'controller\.currentNavigationIndex\.value', 'container.read(dashboardControllerProvider).currentNavigationIndex', c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)
