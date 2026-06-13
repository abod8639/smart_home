import re
with open('lib/features/dashboard/presentation/controllers/dashboard_controller.dart', 'r') as f:
    c = f.read()

# I will just replace the whole `void _initFirebaseListeners() {` and whatever is after it down to the next `void ` or end of file
c = re.sub(r'void _initFirebaseListeners\(\)\s*\{.*?\}\s*\}\s*\}\s*', 'void _initFirebaseListeners() {}\n', c, flags=re.DOTALL)

with open('lib/features/dashboard/presentation/controllers/dashboard_controller.dart', 'w') as f:
    f.write(c)
