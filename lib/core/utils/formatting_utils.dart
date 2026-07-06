class FormattingUtils {
  /// Format time to: h:mm AM/PM (e.g. 12:30 PM)
  static String formatTime(DateTime time) {
    final minutesStr = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    return '$hour:$minutesStr $ampm';
  }

  /// Format date to: Weekday, Month Day (e.g. Monday, January 1)
  static String formatDate(DateTime date) {
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  /// Format a duration (e.g. 1h 15m or 35m)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m left';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins > 0) {
        return '${hours}h ${mins}m';
      }
      return '${hours}h left';
    }
  }

  /// Format cooling time (e.g. 1h 15m or 35 min)
  static String formatCoolingTime(int? totalMinutes) {
    if (totalMinutes == null || totalMinutes == 0) return '0 min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '$minutes min';
    }
  }

  /// Returns the background image asset path for a given room name.
  static String getRoomBackgroundImage(String? roomName) {
    if (roomName == null) return 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png';
    switch (roomName.toLowerCase()) {
      case 'kitchen':
        return 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/kitchen.png';
      case 'bedroom':
        return 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bedroom.png';
      case 'bathroom':
        return 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bathroom.png';
      case 'living room':
      default:
        return 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png';
    }
  }
}
