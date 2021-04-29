import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_lap.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_serializable.dart';

void main() {
  test('FitLap has the expected global message number', () async {
    final lap = FitLap(0);

    expect(lap.globalMessageNumber, FitMessage.Lap);
  });

  test('FitLap data has the expected length', () async {
    final rng = Random();
    final lap = FitLap(0);
    final now = DateTime.now();
    final exportRecord = ExportRecord()
      ..timeStampInteger = FitSerializable.fitDateTime(now)
      ..latitude = rng.nextDouble()
      ..longitude = rng.nextDouble();
    final exportModel = ExportModel()
      ..dateActivity = now
      ..records = [exportRecord]
      ..totalTime = 0.0
      ..totalDistance = 0.0
      ..calories = 0
      ..averageSpeed = 0.0
      ..maximumSpeed = 0.0
      ..averageHeartRate = 0
      ..maximumHeartRate = 0
      ..averageCadence = 0
      ..maximumCadence = 0
      ..averagePower = 0.0
      ..maximumPower = 0.0;

    final output = lap.serializeData(exportModel);
    final expected = lap.fields.fold(0, (accu, field) => accu + field.size);

    expect(output.length, expected + 1);
  });
}
