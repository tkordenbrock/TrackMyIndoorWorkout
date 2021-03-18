import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:preferences/preference_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../device_descriptors/device_descriptor.dart';
import '../bluetooth_device_ex.dart';
import '../gatt_constants.dart';
import 'device_base.dart';
import 'heart_rate_monitor.dart';

typedef RecordHandlerFunction = Function(Record data);

class FitnessEquipment extends DeviceBase {
  final DeviceDescriptor descriptor;
  double _residueCalories;
  int _lastPositiveCadence; // #101
  double _lastPositiveCalories; // #111
  bool hasTotalCalorieCounting;
  bool _calorieCarryoverWorkaround = CALORIE_CARRYOVER_WORKAROUND_DEFAULT;
  Timer _timer;
  Record lastRecord;
  HeartRateMonitor heartRateMonitor;
  Activity _activity;
  bool measuring;
  Random _random;

  FitnessEquipment({this.descriptor, device})
      : assert(descriptor != null),
        super(
          serviceId: descriptor.dataServiceId,
          characteristicsId: descriptor.dataCharacteristicId,
          device: device,
        ) {
    _residueCalories = 0.0;
    _lastPositiveCadence = 0;
    _lastPositiveCalories = 0.0;
    hasTotalCalorieCounting = false;
    _calorieCarryoverWorkaround = PrefService.getBool(CALORIE_CARRYOVER_WORKAROUND_TAG) ?? true;
    measuring = false;
    _random = Random();
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? true;
    lastRecord = RecordWithSport(
      timeStamp: 0,
      distance: uxDebug ? _random.nextInt(5000).toDouble() : 0.0,
      elapsed: 0,
      calories: 0,
      power: 0,
      speed: 0.0,
      cadence: 0,
      heartRate: 0,
      elapsedMillis: 0,
      sport: descriptor.sport,
    );
  }

  Stream<Record> get _listenToData async* {
    if (!attached) return;
    await for (var byteString in characteristic.value.throttleTime(Duration(milliseconds: 500))) {
      if (!descriptor.canDataProcessed(byteString)) continue;
      if (!measuring) continue;

      final record = descriptor.stubRecord(byteString);
      if (record == null) continue;
      yield record;
    }
  }

  pumpData(RecordHandlerFunction recordHandlerFunction) {
    if (uxDebug) {
      _timer = Timer(
        Duration(seconds: 1),
        () {
          final record = processRecord(Record(
            timeStamp: DateTime.now().millisecondsSinceEpoch,
            calories: _random.nextInt(1500),
            power: 50 + _random.nextInt(500),
            speed: 15.0 + _random.nextDouble() * 15.0,
            cadence: 30 + _random.nextInt(100),
            heartRate: 60 + _random.nextInt(120),
            sport: descriptor.sport,
          ));
          recordHandlerFunction(record);
          pumpData(recordHandlerFunction);
        },
      );
    } else {
      subscription = _listenToData.listen((recordStub) {
        final record = processRecord(recordStub);
        recordHandlerFunction(record);
      });
    }
  }

  setHeartRateMonitor(HeartRateMonitor heartRateMonitor) {
    this.heartRateMonitor = heartRateMonitor;
  }

  setActivity(Activity activity) {
    this._activity = activity;
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? true;
  }

  Future<bool> discover({bool retry = false}) async {
    if (uxDebug) return true;
    final success = await super.discover(retry: retry);
    if (!success) return false;

    // Check manufacturer name
    // Will need to elaborate when generic GATT Fitness Machine support is added
    final deviceInfo = BluetoothDeviceEx.filterService(services, DEVICE_INFORMATION_ID);
    final nameCharacteristic =
        BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, MANUFACTURER_NAME_ID);
    var nameString;
    try {
      final nameBytes = await nameCharacteristic.read();
      nameString = String.fromCharCodes(nameBytes);
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
      // 2nd try
      try {
        final nameBytes = await nameCharacteristic.read();
        nameString = String.fromCharCodes(nameBytes);
      } on PlatformException catch (e, stack) {
        debugPrint("${e.message}");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }
    }

    return nameString == descriptor.manufacturer;
  }

  Record processRecord(Record stub) {
    final now = DateTime.now();
    int elapsedMillis = now.difference(_activity?.startDateTime ?? now).inMilliseconds;
    double elapsed = elapsedMillis / 1000.0;
    // When the equipment supplied multiple data read per second but the Fitness Machine
    // standard only supplies second resolution elapsed time the delta time becomes zero
    // Therefore the FTMS elapsed time reading is kinda useless, causes problems.
    // With this fix the calorie zeroing bug is revealed. Calorie preserving workaround can be
    // toggled in the settings now. Only the distance perseverance could pose a glitch. #94
    hasTotalCalorieCounting =
        hasTotalCalorieCounting || (stub.calories != null && stub.calories > 0);
    if (hasTotalCalorieCounting && (stub.elapsed ?? 0) > 0) {
      elapsed = stub.elapsed.toDouble();
    }

    if (stub.elapsed == null || stub.elapsed == 0) {
      stub.elapsed = elapsed.round();
    }

    if (stub.elapsedMillis == null || stub.elapsedMillis == 0) {
      stub.elapsedMillis = elapsedMillis;
    }

    final dT = (elapsedMillis - lastRecord.elapsedMillis) / 1000.0;
    if ((stub.distance ?? 0.0) < EPS && (stub.speed ?? 0.0) > 0 && dT > EPS) {
      double dD = stub.speed * DeviceDescriptor.KMH2MS * descriptor.distanceFactor * dT;
      stub.distance = lastRecord.distance + dD;
    }

    var calories = 0.0;
    if (stub.calories != null && stub.calories > 0) {
      calories = stub.calories.toDouble();
      hasTotalCalorieCounting = true;
    } else {
      double deltaCalories = 0;
      if (stub.caloriesPerHour != null && stub.caloriesPerHour > EPS) {
        deltaCalories = stub.caloriesPerHour / (60 * 60) * dT;
      }

      if (deltaCalories < EPS && stub.caloriesPerMinute != null && stub.caloriesPerMinute > EPS) {
        deltaCalories = stub.caloriesPerMinute / 60 * dT;
      }

      if (deltaCalories < EPS && stub.power != null && stub.power > EPS) {
        deltaCalories = stub.power * dT * DeviceDescriptor.J2KCAL * descriptor.calorieFactor;
      }

      if (deltaCalories > 0) {
        _residueCalories += deltaCalories;
        calories = (lastRecord.calories ?? 0) + _residueCalories;
        if (calories.floor() > lastRecord.calories) {
          _residueCalories = calories - calories.floor();
        }
      }
    }

    if (stub.pace != null && stub.pace > 0 && stub.pace < SLOW_PACE ||
        stub.speed != null && stub.speed > EPS) {
      // #101
      if ((stub.cadence == null || stub.cadence == 0) && _lastPositiveCadence > 0) {
        stub.cadence = _lastPositiveCadence;
      } else if (stub.cadence != null && stub.cadence > 0) {
        _lastPositiveCadence = stub.cadence;
      }

      // #111
      if ((calories == null || calories < EPS) && _lastPositiveCalories > 0) {
        calories = _lastPositiveCalories;
      } else if (calories != null && calories > EPS) {
        _lastPositiveCalories = calories;
      }
    }

    if (_calorieCarryoverWorkaround &&
        lastRecord.calories != null &&
        lastRecord.calories > 0 &&
        (calories == null || lastRecord.calories > calories)) {
      calories = lastRecord.calories.toDouble();
    }

    stub.calories = calories?.floor() ?? 0;

    if (stub.heartRate == 0 && (heartRateMonitor?.metric ?? 0) > 0) {
      stub.heartRate = heartRateMonitor.metric;
    }

    // #93
    if (stub.heartRate == 0 && lastRecord.heartRate > 0) {
      stub.heartRate = lastRecord.heartRate;
    }

    stub.activityId = _activity?.id;
    stub.sport = descriptor.sport;
    lastRecord = stub;
    return stub;
  }

  stopWorkout() {
    _calorieCarryoverWorkaround = PrefService.getBool(CALORIE_CARRYOVER_WORKAROUND_TAG) ?? true;
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? true;
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _timer?.cancel();
  }
}
