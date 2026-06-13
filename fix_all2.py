import re

# 1. auth_service.dart
path = 'lib/core/services/auth_service.dart'
with open(path, 'r') as f:
    c = f.read()

c = c.replace(
    "late final GoogleSignIn _googleSignIn;",
    ""
)
c = c.replace(
    "_googleSignIn = GoogleSignIn(\n          serverClientId: '263208865722-jhtj3i34m25u1i0svt1kdktbvukbhtjd.apps.googleusercontent.com',\n          scopes: ['email'],\n        );",
    "GoogleSignIn.instance.initialize(\n          serverClientId: '263208865722-jhtj3i34m25u1i0svt1kdktbvukbhtjd.apps.googleusercontent.com',\n        );"
)
c = c.replace(
    "final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();",
    "final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();"
)
c = c.replace(
    "final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();",
    "final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();"
)
c = c.replace(
    "await _googleSignIn.signOut();",
    "await GoogleSignIn.instance.signOut();"
)
c = c.replace(
    "final GoogleSignInAuthentication googleAuth = await googleUser.authentication;",
    "final GoogleSignInAuthentication googleAuth = googleUser.authentication;" # Removed await
)

with open(path, 'w') as f:
    f.write(c)


# 2. dashboard_controller_test.dart
path = 'test/dashboard_controller_test.dart'
with open(path, 'r') as f:
    c = f.read()

# Remove duplicate `final container = ...` and `final controller = ...` inside tests
# In rewrite_dashboard_test.py, it was doing re.sub of mockFirebase creation to also create the container,
# which resulted in multiple createContainer definitions if the original test code had them, or duplicated container declarations.
# Let's fix the variable shadowing.

# Find all "final container = createContainer" and replace with "container = createContainer" EXCEPT the very first one if it's in a setup block?
# Wait, each `test()` block should have its own container.
# The error was: 'container' is already declared in this scope.
# Because rewrite_dashboard_test.py matched:
# final mockFirebase = MockFirebaseService(); Get.put<FirebaseService>(mockFirebase); Get.put<SettingsController>(MockSettingsController()); Get.put<Esp32Service>(Esp32Service()); final mockMatter = Get.put<MatterService>(MockMatterService());
# And replaced it with final container = createContainer(...);
# AND the original code might have ALREADY had some other declarations?
# Let's just fix it by replacing `final container = ` with `var container = ` if we want, but wait, it's declared twice IN THE SAME SCOPE!
# Where was it declared? Let's check test/dashboard_controller_test.dart lines 348 and 353.
