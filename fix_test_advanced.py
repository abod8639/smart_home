import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    if 'Get.reset();' in line or 'Get.testMode = true;' in line:
        i += 1
        continue
    
    if 'final controller = Get.put(DashboardController());' in line:
        mocks = []
        has_firebase = False
        has_settings = False
        has_esp32 = False
        has_matter = False
        
        j = i + 1
        # Look ahead up to 6 lines to gather mocks
        while j < len(lines) and j <= i + 6:
            if 'MockFirebaseService' in lines[j] and 'Get.put' in lines[j]:
                has_firebase = True
            if 'MockSettingsController' in lines[j] and 'Get.put' in lines[j]:
                has_settings = True
            if 'Esp32Service' in lines[j] and 'Get.put' in lines[j]:
                has_esp32 = True
            if 'MockMatterService' in lines[j] and 'Get.put' in lines[j]:
                has_matter = True
            if 'Get.put<' not in lines[j] and 'final mock' not in lines[j] and lines[j].strip() != '':
                break
            j += 1
        
        indent = re.match(r'^\s*', line).group(0)
        
        if has_firebase or has_settings or has_esp32 or has_matter:
            if has_firebase:
                new_lines.append(indent + "final mockFirebase = MockFirebaseService();\n")
            if has_matter:
                new_lines.append(indent + "final mockMatter = MockMatterService();\n")
                
            new_lines.append(indent + "final container = createContainer(overrides: [\n")
            if has_firebase:
                new_lines.append(indent + "  firebaseServiceProvider.overrideWith((ref) => mockFirebase),\n")
            if has_settings:
                new_lines.append(indent + "  settingsControllerProvider.overrideWith(() => MockSettingsController()),\n")
            if has_esp32:
                new_lines.append(indent + "  esp32ServiceProvider.overrideWith((ref) => Esp32Service()),\n")
            if has_matter:
                new_lines.append(indent + "  matterServiceProvider.overrideWith((ref) => mockMatter),\n")
            new_lines.append(indent + "]);\n")
            new_lines.append(indent + "final controller = container.read(dashboardControllerProvider.notifier);\n")
            i = j
            continue
        else:
            # Just create container
            new_lines.append(indent + "final container = createContainer();\n")
            new_lines.append(indent + "final controller = container.read(dashboardControllerProvider.notifier);\n")
            i += 1
            continue

    if 'Get.put<' in line:
        i += 1
        continue

    # Fix bad overrideWith that might have been left behind by my previous scripts
    if 'firebaseServiceProvider.overrideWith(() => mockFirebase)' in line:
        line = line.replace('() => mockFirebase', '(ref) => mockFirebase')
    if 'esp32ServiceProvider.overrideWith(() => Esp32Service())' in line:
        line = line.replace('() => Esp32Service()', '(ref) => Esp32Service()')
    if 'matterServiceProvider.overrideWith(() => mockMatter)' in line:
        line = line.replace('() => mockMatter', '(ref) => mockMatter')
    if 'settingsControllerProvider.overrideWith(() => MockSettingsController())' in line:
        # SettingsController is a Notifier, so overrideWith takes `() => MockSettingsController()`
        pass

    new_lines.append(line)
    i += 1

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.writelines(new_lines)
