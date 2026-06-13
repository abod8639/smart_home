import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# Replace method calls with tester.element(find.byType(Container))
c = re.sub(r"controller\.setAcMode\('ac_test_mode'", "controller.setAcMode(tester.element(find.byType(Container)), 'ac_test_mode'", c)
c = re.sub(r"controller\.clearIrCode\('ac_clear'", "controller.clearIrCode(tester.element(find.byType(Container)), 'ac_clear'", c)
c = re.sub(r"controller\.setAcSleepTimer\('ac_timer'", "controller.setAcSleepTimer(tester.element(find.byType(Container)), 'ac_timer'", c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)
