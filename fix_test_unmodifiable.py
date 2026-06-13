import re

# 1. Add setDevicesForTest and setRoomsForTest to dashboard_controller.dart
with open('lib/features/dashboard/presentation/controllers/dashboard_controller.dart', 'r') as f:
    c = f.read()

if 'void setDevicesForTest' not in c:
    c = c.replace('void setHeapFree(String val) => state = state.copyWith(heapFree: val);', 
                  'void setHeapFree(String val) => state = state.copyWith(heapFree: val);\n\n  @visibleForTesting\n  void setDevicesForTest(List<DeviceEntity> devices) => state = state.copyWith(devices: devices);\n  @visibleForTesting\n  void setRoomsForTest(List<RoomEntity> rooms) => state = state.copyWith(rooms: rooms);')
    with open('lib/features/dashboard/presentation/controllers/dashboard_controller.dart', 'w') as f:
        f.write(c)

# 2. Fix the test usages
with open('test/dashboard_controller_test.dart', 'r') as f:
    t = f.read()

# For clear:
# container.read(dashboardControllerProvider).devices.clear(); -> controller.setDevicesForTest([]);
t = re.sub(r'container\.read\(dashboardControllerProvider\)\.devices\.clear\(\);', 'controller.setDevicesForTest([]);', t)

# For add:
# container.read(dashboardControllerProvider).devices.add(device); -> controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, device]);
t = re.sub(r'container\.read\(dashboardControllerProvider\)\.devices\.add\((.*?)\);', r'controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, \1]);', t)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(t)
