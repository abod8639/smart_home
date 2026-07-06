import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';

void main() {
  group('FormattingUtils', () {
    // ── formatTime ────────────────────────────────────────────────────────────
    group('formatTime', () {
      test('formats midnight as 12:00 AM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 0, 0)), '12:00 AM');
      });

      test('formats noon as 12:00 PM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 12, 0)), '12:00 PM');
      });

      test('formats 1:05 AM correctly (leading zero on minutes)', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 1, 5)), '1:05 AM');
      });

      test('formats 11:59 AM correctly', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 11, 59)), '11:59 AM');
      });

      test('formats 13:00 as 1:00 PM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 13, 0)), '1:00 PM');
      });

      test('formats 23:59 as 11:59 PM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 23, 59)), '11:59 PM');
      });

      test('formats 15:30 as 3:30 PM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 15, 30)), '3:30 PM');
      });

      test('formats 9:09 AM with leading zero on minutes', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 9, 9)), '9:09 AM');
      });

      test('formats 12:30 PM correctly', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 12, 30)), '12:30 PM');
      });

      test('formats 0:45 as 12:45 AM', () {
        expect(FormattingUtils.formatTime(DateTime(2024, 1, 1, 0, 45)), '12:45 AM');
      });
    });

    // ── formatDate ────────────────────────────────────────────────────────────
    group('formatDate', () {
      test('formats Monday correctly', () {
        // 2024-01-01 is a Monday
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 1)), 'Monday, January 1');
      });

      test('formats Tuesday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 2)), 'Tuesday, January 2');
      });

      test('formats Wednesday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 3)), 'Wednesday, January 3');
      });

      test('formats Thursday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 4)), 'Thursday, January 4');
      });

      test('formats Friday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 5)), 'Friday, January 5');
      });

      test('formats Saturday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 6)), 'Saturday, January 6');
      });

      test('formats Sunday correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 7)), 'Sunday, January 7');
      });

      test('formats February correctly', () {
        // 2024-02-14 is a Wednesday
        expect(FormattingUtils.formatDate(DateTime(2024, 2, 14)), 'Wednesday, February 14');
      });

      test('formats March correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 3, 1)), contains('March'));
      });

      test('formats April correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 4, 1)), contains('April'));
      });

      test('formats May correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 5, 1)), contains('May'));
      });

      test('formats June correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 6, 1)), contains('June'));
      });

      test('formats July correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 7, 1)), contains('July'));
      });

      test('formats August correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 8, 1)), contains('August'));
      });

      test('formats September correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 9, 1)), contains('September'));
      });

      test('formats October correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 10, 1)), contains('October'));
      });

      test('formats November correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 11, 1)), contains('November'));
      });

      test('formats December correctly', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 12, 25)), contains('December'));
      });

      test('includes day number', () {
        expect(FormattingUtils.formatDate(DateTime(2024, 1, 15)), contains('15'));
      });
    });

    // ── formatDuration ────────────────────────────────────────────────────────
    group('formatDuration', () {
      test('formats 0 minutes as 0m left', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 0)), '0m left');
      });

      test('formats 30 minutes as 30m left', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 30)), '30m left');
      });

      test('formats 59 minutes as 59m left', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 59)), '59m left');
      });

      test('formats exactly 60 minutes as 1h left', () {
        expect(FormattingUtils.formatDuration(const Duration(hours: 1)), '1h left');
      });

      test('formats 90 minutes as 1h 30m', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 90)), '1h 30m');
      });

      test('formats 120 minutes as 2h left', () {
        expect(FormattingUtils.formatDuration(const Duration(hours: 2)), '2h left');
      });

      test('formats 75 minutes as 1h 15m', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 75)), '1h 15m');
      });

      test('formats 3h 5m correctly', () {
        expect(FormattingUtils.formatDuration(const Duration(hours: 3, minutes: 5)), '3h 5m');
      });

      test('formats 1 minute as 1m left', () {
        expect(FormattingUtils.formatDuration(const Duration(minutes: 1)), '1m left');
      });
    });

    // ── formatCoolingTime ─────────────────────────────────────────────────────
    group('formatCoolingTime', () {
      test('returns 0 min for null input', () {
        expect(FormattingUtils.formatCoolingTime(null), '0 min');
      });

      test('returns 0 min for zero input', () {
        expect(FormattingUtils.formatCoolingTime(0), '0 min');
      });

      test('formats 30 minutes as 30 min', () {
        expect(FormattingUtils.formatCoolingTime(30), '30 min');
      });

      test('formats 59 minutes as 59 min', () {
        expect(FormattingUtils.formatCoolingTime(59), '59 min');
      });

      test('formats exactly 60 minutes as 1h', () {
        expect(FormattingUtils.formatCoolingTime(60), '1h');
      });

      test('formats 90 minutes as 1h 30m', () {
        expect(FormattingUtils.formatCoolingTime(90), '1h 30m');
      });

      test('formats 120 minutes as 2h', () {
        expect(FormattingUtils.formatCoolingTime(120), '2h');
      });

      test('formats 75 minutes as 1h 15m', () {
        expect(FormattingUtils.formatCoolingTime(75), '1h 15m');
      });

      test('formats 1 minute as 1 min', () {
        expect(FormattingUtils.formatCoolingTime(1), '1 min');
      });

      test('formats large value correctly', () {
        // 125 min = 2h 5m
        expect(FormattingUtils.formatCoolingTime(125), '2h 5m');
      });
    });

    // ── getRoomBackgroundImage ────────────────────────────────────────────────
    group('getRoomBackgroundImage', () {
      test('returns living room image for null name', () {
        expect(
          FormattingUtils.getRoomBackgroundImage(null),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png',
        );
      });

      test('returns kitchen image for "kitchen"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('kitchen'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/kitchen.png',
        );
      });

      test('returns kitchen image for "Kitchen" (case-insensitive)', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('Kitchen'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/kitchen.png',
        );
      });

      test('returns kitchen image for "KITCHEN" (case-insensitive)', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('KITCHEN'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/kitchen.png',
        );
      });

      test('returns bedroom image for "bedroom"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('bedroom'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bedroom.png',
        );
      });

      test('returns bedroom image for "Bedroom"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('Bedroom'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bedroom.png',
        );
      });

      test('returns bathroom image for "bathroom"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('bathroom'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bathroom.png',
        );
      });

      test('returns bathroom image for "Bathroom"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('Bathroom'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/bathroom.png',
        );
      });

      test('returns living room image for "living room"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('living room'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png',
        );
      });

      test('returns living room image for "Living Room"', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('Living Room'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png',
        );
      });

      test('returns living room image for unknown room name (default)', () {
        expect(
          FormattingUtils.getRoomBackgroundImage('office'),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png',
        );
      });

      test('returns living room image for empty string (default)', () {
        expect(
          FormattingUtils.getRoomBackgroundImage(''),
          'https://raw.githubusercontent.com/abod8639/media/main/smart_home/living_room.png',
        );
      });

      test('all returned URLs use raw.githubusercontent.com domain', () {
        final rooms = [null, 'kitchen', 'bedroom', 'bathroom', 'living room', 'unknown'];
        for (final room in rooms) {
          final url = FormattingUtils.getRoomBackgroundImage(room);
          expect(url, startsWith('https://raw.githubusercontent.com/'),
              reason: 'Expected raw URL for room: $room');
        }
      });
    });
  });
}
