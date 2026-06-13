with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

c = c.replace('.overrideWith((_) => mockFirebase)', '.overrideWith(() => mockFirebase)')

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)
