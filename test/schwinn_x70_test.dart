import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Schwinn X70 constructor tests', () async {
    final bike = deviceMap[schwinnX70BikeFourCC]!;

    expect(bike.canMeasureHeartRate, false);
    expect(bike.defaultSport, ActivityType.ride);
    expect(bike.fourCC, schwinnX70BikeFourCC);
  });

  test('Schwinn X70 interprets Data flags properly', () async {
    final bike = deviceMap[schwinnX70BikeFourCC]!;
    final data = [17, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    expect(bike.isDataProcessable(data), true);
    expect(bike.speedMetric, null);
    expect(bike.cadenceMetric, isNotNull);
    expect(bike.distanceMetric, null);
    expect(bike.powerMetric, null);
    expect(bike.caloriesMetric, isNotNull);
    expect(bike.timeMetric, isNotNull);
    expect(bike.caloriesPerHourMetric, null);
    expect(bike.caloriesPerMinuteMetric, null);
  });

  group('Schwinn 270 interprets Data properly', () {
    for (final testPair in [
      // 15:34:57.050
      TestPair(
        data: [17, 32, 0, 160, 5, 0, 0, 226, 111, 253, 76, 96, 17, 0, 0, 0, 4],
        record: RecordWithSport(
          distance: null,
          elapsed: 63,
          calories: 4448,
          power: null,
          speed: null,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 63358,
        ),
      ),
      // 15:35:08.115
      TestPair(
        data: [17, 32, 0, 96, 12, 0, 0, 224, 114, 42, 187, 92, 44, 0, 0, 0, 4],
        record: RecordWithSport(
          distance: null,
          elapsed: 10,
          calories: 11356,
          power: null,
          speed: null,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 10611,
        ),
      ),
      // 15:35:20.899
      TestPair(
        data: [17, 32, 0, 96, 19, 0, 0, 12, 121, 94, 148, 75, 72, 0, 0, 0, 4],
        record: RecordWithSport(
          distance: null,
          elapsed: 23,
          calories: 18507,
          power: null,
          speed: null,
          cadence: 0,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 23618,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final bike = deviceMap[schwinnX70BikeFourCC]!;
        expect(bike.isDataProcessable(testPair.data), true);

        final record = bike.wrappedStubRecord(testPair.data)!;

        expect(record.id, null);
        expect(record.id, testPair.record.id);
        expect(record.activityId, null);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.calories, testPair.record.calories);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.pace, testPair.record.pace);
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
      });
    }
  });

  group('Schwinn 570u interprets Data properly', () {
    for (final testPair in [
      TestPair(
        // 18:56:52.831
        data: [17, 32, 0, 0, 245, 248, 0, 0, 32, 101, 33, 102, 0, 0, 0, 0, 7],
        record: RecordWithSport(
          distance: null,
          elapsed: 25,
          calories: 102,
          power: null,
          speed: null,
          cadence: 2520,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 25281,
        ),
      ),
      // 19:05:28.798
      TestPair(
        data: [17, 32, 0, 0, 127, 251, 0, 0, 89, 135, 112, 164, 139, 8, 0, 0, 10],
        record: RecordWithSport(
          distance: null,
          elapsed: 33,
          calories: 560036,
          power: null,
          speed: null,
          cadence: 1902,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 33836,
        ),
      ),
      // 19:05:34.035
      TestPair(
        data: [17, 32, 0, 0, 133, 251, 0, 128, 63, 156, 32, 243, 160, 8, 0, 0, 10],
        record: RecordWithSport(
          distance: null,
          elapsed: 39,
          calories: 565491,
          power: null,
          speed: null,
          cadence: 1648,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 39061,
        ),
      ),
      // Glitch happened here
      // 19:06:20.093
      TestPair(
        data: [17, 32, 0, 64, 133, 251, 0, 0, 135, 82, 128, 190, 161, 8, 0, 0, 10],
        record: RecordWithSport(
          distance: null,
          elapsed: 20,
          calories: 565694,
          power: null,
          speed: null,
          cadence: 3120,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 20631,
        ),
      ),
      // 19:14:42.015
      TestPair(
        data: [17, 32, 0, 64, 250, 253, 0, 0, 110, 62, 64, 109, 40, 17, 0, 0, 11],
        record: RecordWithSport(
          distance: null,
          elapsed: 15,
          calories: 1124461,
          power: null,
          speed: null,
          cadence: 4165,
          heartRate: null,
          pace: null,
          sport: ActivityType.ride,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          elapsedMillis: 15607,
        ),
      ),
    ]) {
      final sum = testPair.data.fold<double>(0.0, (a, b) => a + b);
      test("$sum", () async {
        final bike = deviceMap[schwinnX70BikeFourCC]!;
        expect(bike.isDataProcessable(testPair.data), true);
        bike.stopWorkout();

        final record = bike.wrappedStubRecord(testPair.data)!;

        expect(record.id, null);
        expect(record.id, testPair.record.id);
        expect(record.activityId, null);
        expect(record.activityId, testPair.record.activityId);
        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.calories, testPair.record.calories);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
        expect(record.pace, testPair.record.pace);
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.sport, testPair.record.sport);
        expect(record.caloriesPerHour, testPair.record.caloriesPerHour);
        expect(record.caloriesPerMinute, testPair.record.caloriesPerMinute);
        expect(record.elapsedMillis, testPair.record.elapsedMillis);
      });
    }
  });
}
