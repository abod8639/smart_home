with open('test/dashboard_controller_test.dart', 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if line.startswith('<<<<<<<'):
        continue
    if line.startswith('======='):
        skip = True
        continue
    if line.startswith('>>>>>>>'):
        skip = False
        continue
    if not skip:
        new_lines.append(line)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.writelines(new_lines)
