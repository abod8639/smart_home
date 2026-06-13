import re
import os

path = "lib/features/settings/presentation/widgets/fcm_token_card.dart"
if os.path.exists(path):
    with open(path, 'r') as f:
        c = f.read()
    
    # We need to replace controller.hasPermission.value with ref.watch(hasNotificationPermissionProvider)
    # But wait, we imported notification_service.dart right?
    # So it should be ref.watch(hasNotificationPermissionProvider)
    c = c.replace("state.hasPermission", "ref.watch(hasNotificationPermissionProvider)")
    c = c.replace("state.fcmToken", "ref.watch(fcmTokenProvider)")
    
    with open(path, 'w') as f:
        f.write(c)

