import re

with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# Fix overrideWith
c = re.sub(r'\.overrideWith\(\(ref\) => mockFirebase\)', '.overrideWith((_) => mockFirebase)', c)
c = re.sub(r'\.overrideWith\(\(ref\) => mockEsp32\)', '.overrideWith((_) => mockEsp32)', c)

# Fix mockMatter undefined
c = re.sub(r'(final mockFirebase = MockFirebaseService\(\);)', r'\1\n        final mockMatter = MockMatterService();', c)

# Add imports
imports = """
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
"""
c = re.sub(r"import 'package:flutter_test/flutter_test\.dart';", f"import 'package:flutter_test/flutter_test.dart';{imports}", c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)

