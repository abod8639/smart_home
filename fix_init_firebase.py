import re

path = 'lib/features/dashboard/presentation/controllers/dashboard_controller.dart'
with open(path, 'r') as f:
    c = f.read()

c = re.sub(r'void _initFirebaseListeners\(\) \{[\s\S]*?\}\n\s*\}', 'void _initFirebaseListeners() {\n  }', c)

with open(path, 'w') as f:
    f.write(c)
