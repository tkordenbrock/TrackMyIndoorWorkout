import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'utils.dart';

void main() {
  group("speedTitle is pace for everything else than Ride", () {
    for (final sport in sports) {
      final expected = sport == ActivityType.ride ? "Speed" : "Pace";
      test("$sport -> $expected", () {
        expect(speedTitle(sport), expected);
      });
    }
  });
}
