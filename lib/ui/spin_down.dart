import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:track_my_indoor_exercise/devices/fitness_machine_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/device_descriptor.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';

class SpinDownBottomSheet extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;

  SpinDownBottomSheet({
    Key key,
    @required this.device,
    @required this.descriptor,
  })  : assert(device != null),
        assert(descriptor != null),
        super(key: key);

  @override
  _SpinDownBottomSheetState createState() => _SpinDownBottomSheetState(
        device: device,
        descriptor: descriptor,
      );
}

enum CalibrationState {
  PreInit,
  Initializing,
  ReadyToWeighIn,
  WeightSubmitting,
  WeighInProblem,
  WeighInSuccess,
  ReadyToCalibrate,
  CalibrationInProgress,
  CalibrationSuccess,
  CalibrationFail,
  NotSupported,
}

class _SpinDownBottomSheetState extends State<SpinDownBottomSheet> {
  static const STEP_WEIGHT_INPUT = 0;
  static const STEP_CALIBRATING = 1;
  static const STEP_DONE = 2;
  static const STEP_NOT_SUPPORTED = 3;

  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  HeartRateMonitor _heartRateMonitor;
  String _hrmBatteryLevel;
  String _batteryLevel;
  double _sizeDefault;
  TextStyle _smallerTextStyle;
  TextStyle _largerTextStyle;
  bool _si;
  int _step;
  int _weight;
  BluetoothCharacteristic _weightData;
  StreamSubscription _weightDataSubscription;
  BluetoothCharacteristic _controlPoint;
  StreamSubscription _controlPointSubscription;
  BluetoothCharacteristic _fitnessMachineStatus;
  BluetoothCharacteristic _fitnessMachineData;
  CalibrationState _calibrationState;
  double _targetSpeedHigh;
  double _targetSpeedLow;
  double _currentSpeed;

  bool get _spinDownPossible =>
      _weightData != null &&
      _controlPoint != null &&
      _fitnessMachineStatus != null &&
      _fitnessMachineData != null;
  bool get _canSubmitWeight =>
      _spinDownPossible && _calibrationState == CalibrationState.ReadyToWeighIn;

  _SpinDownBottomSheetState({
    @required this.device,
    @required this.descriptor,
  }) : assert(device != null);

  _prepareSpinDown(List<BluetoothService> services) async {
    final userData = BluetoothDeviceEx.filterService(services, USER_DATA_SERVICE);
    _weightData =
        BluetoothDeviceEx.filterCharacteristic(userData?.characteristics, WEIGHT_CHARACTERISTIC);
    final fitnessMachine = BluetoothDeviceEx.filterService(services, FITNESS_MACHINE_ID);
    _controlPoint = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_CONTROL_POINT);
    _fitnessMachineStatus = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_STATUS);
    final dataService = descriptor.isFitnessMachine
        ? fitnessMachine
        : BluetoothDeviceEx.filterService(services, descriptor.primaryServiceId);
    _fitnessMachineData = BluetoothDeviceEx.filterCharacteristic(dataService?.characteristics,
        (descriptor as FitnessMachineDescriptor).primaryMeasurementId);
    setState(() {
      if (!_spinDownPossible) {
        _step = STEP_NOT_SUPPORTED;
        _calibrationState = CalibrationState.NotSupported;
      } else {
        _calibrationState = CalibrationState.ReadyToWeighIn;
      }
    });
  }

  Future<String> _readBatteryLevel(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, BATTERY_SERVICE_ID);
    if (batteryService == null) {
      return "N/A";
    }
    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, BATTERY_LEVEL_ID);
    if (batteryLevel == null) {
      return "N/A";
    }
    final batteryLevelData = await batteryLevel.read();
    return "${batteryLevelData[0]}%";
  }

  _readBatteryLevels() async {
    setState(() {
      _calibrationState = CalibrationState.Initializing;
    });
    if (_heartRateMonitor?.connected ?? false) {
      _heartRateMonitor.device.discoverServices().then((services) async {
        final batteryLevel = await _readBatteryLevel(services);
        setState(() {
          _hrmBatteryLevel = batteryLevel;
        });
      });
    } else {
      setState(() {
        _hrmBatteryLevel = "N/A";
      });
    }
    device.discoverServices().then((services) async {
      await _prepareSpinDown(services);
      final batteryLevel = await _readBatteryLevel(services);
      setState(() {
        _batteryLevel = batteryLevel;
      });
    });
  }

  String _weightInputButtonText() {
    if (_calibrationState == CalibrationState.WeighInSuccess) return 'Next >';
    if (_calibrationState == CalibrationState.ReadyToWeighIn) return 'Submit';
    if (_calibrationState == CalibrationState.WeighInProblem) return 'Retry';

    return 'Wait...';
  }

  TextStyle _weightInputButtonTextStyle() {
    return _smallerTextStyle.merge(TextStyle(
        color: _calibrationState == CalibrationState.WeighInSuccess || _canSubmitWeight
            ? Colors.black
            : Colors.black54));
  }

  ButtonStyle _weightInputButtonStyle() {
    return ElevatedButton.styleFrom(
      primary: _calibrationState == CalibrationState.WeighInSuccess || _canSubmitWeight
          ? Colors.lightGreen.shade100
          : Colors.black12,
    );
  }

  Future<void> _onWeightInputButtonPressed() async {
    if (_calibrationState == CalibrationState.WeighInSuccess) {
      setState(() {
        _step = STEP_CALIBRATING;
        _calibrationState = CalibrationState.ReadyToCalibrate;
      });
      return;
    }

    if (_calibrationState == CalibrationState.PreInit ||
        _calibrationState == CalibrationState.Initializing) {
      Get.snackbar("Please wait", "Initializing equipment for calibration...");
      return;
    }
    if (_calibrationState == CalibrationState.WeightSubmitting) {
      Get.snackbar("Please wait", "Weight submission is in progress...");
      return;
    }

    setState(() {
      _calibrationState = CalibrationState.WeightSubmitting;
    });
    final weight = (_si ? _weight : _weight * LB_TO_KG) * 100;
    final weightLsb = weight % 256;
    final weightMsb = weight ~/ 256;
    await _weightData.setNotifyValue(true);
    _weightDataSubscription = _weightData.value.listen((response) async {
      if (response?.length == 1) {
        debugPrint("Weight response 1 ${response[0]}");
        if (response[0] != WEIGHT_SUCCESS_OPCODE) {
          Get.snackbar("Weight setting error", "Retry weight setting to continue");
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        }
      } else if (response?.length == 2) {
        debugPrint("Weight response 2 ${response[0]} ${response[1]}");
        if (response[0] != weightLsb || response[1] != weightMsb) {
          Get.snackbar("Weight setting error", "Retry weight setting to continue");
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        } else {
          Get.snackbar("Weight setting", "Successful");
          setState(() {
            _calibrationState = CalibrationState.WeighInSuccess;
          });
        }
      } else {
        debugPrint("Weight response X $response");
      }
    });
    await _weightData.write([weightLsb, weightMsb]);
  }

  String _calibrationInstruction() {
    if (_calibrationState == CalibrationState.ReadyToCalibrate) return "START!";

    if (_calibrationState == CalibrationState.CalibrationInProgress) return "FASTER!";

    return "STOP!!!";
  }

  String _calibrationButtonText() {
    return _calibrationState == CalibrationState.ReadyToCalibrate ? 'Start' : 'Stop';
  }

  Future<void> onCalibrationButtonPressed() async {
    if (_calibrationState == CalibrationState.CalibrationInProgress) {
      Get.snackbar("Calibration", "Wait for instructions!");
      return;
    }
    setState(() {
      _calibrationState = CalibrationState.CalibrationInProgress;
    });
    await _controlPoint.setNotifyValue(true); // Is this needed for indication?
    _controlPointSubscription = _controlPoint.value.listen((data) async {
      if (data?.length != 1 || data[0] != SPIN_DOWN_OPCODE) {
        Get.snackbar("Calibration Start error", "Please retry");
        setState(() {
          _step = STEP_DONE;
          _calibrationState = CalibrationState.CalibrationFail;
        });
      }
      final spinDownData = await _controlPoint.read();
      if (spinDownData?.length != 7 ||
          spinDownData[0] != CONTROL_OPCODE ||
          spinDownData[1] != SPIN_DOWN_OPCODE ||
          spinDownData[2] != SUCCESS_RESPONSE) {
        Get.snackbar("Calibration Start error", "Please retry");
        setState(() {
          _step = STEP_DONE;
          _calibrationState = CalibrationState.CalibrationFail;
        });
        return;
      }
      _targetSpeedHigh = (spinDownData[3] * 256 + spinDownData[4]) / 100;
      _targetSpeedLow = (spinDownData[5] * 256 + spinDownData[6]) / 100;
      Get.snackbar("Calibration started", "Go!");
      _controlPoint.setNotifyValue(true);
      _controlPointSubscription = _controlPoint.value.listen((data) {
        ;
      });
    });
    await _controlPoint.write([SPIN_DOWN_OPCODE, SPIN_DOWN_START_COMMAND]);
  }

  @override
  initState() {
    super.initState();
    _hrmBatteryLevel = "N/A";
    _batteryLevel = "N/A";
    _step = STEP_WEIGHT_INPUT;
    _calibrationState = CalibrationState.PreInit;
    _targetSpeedHigh = 0.0;
    _targetSpeedLow = 0.0;
    _currentSpeed = 0.0;
    _weight = 50;
    _sizeDefault = Get.mediaQuery.size.width / 10;
    _smallerTextStyle = TextStyle(
        fontFamily: FONT_FAMILY, fontSize: _sizeDefault, color: Get.textTheme.bodyText1.color);
    _largerTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault * 2);
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _readBatteryLevels();
  }

  @override
  dispose() {
    _controlPointSubscription?.cancel();
    _controlPoint?.setNotifyValue(false);

    _weightDataSubscription?.cancel();
    _weightData?.setNotifyValue(false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _hrmBatteryLevel == null
                  ? JumpingDotsProgressIndicator(fontSize: _sizeDefault)
                  : Row(children: [
                      Icon(Icons.battery_unknown, color: Colors.indigo, size: _sizeDefault),
                      Text(_batteryLevel, style: _smallerTextStyle),
                    ]),
              _hrmBatteryLevel == null
                  ? JumpingDotsProgressIndicator(fontSize: _sizeDefault)
                  : Row(children: [
                      Icon(Icons.favorite, color: Colors.indigo, size: _sizeDefault),
                      Icon(Icons.battery_unknown, color: Colors.indigo, size: _sizeDefault),
                      Text(_hrmBatteryLevel, style: _smallerTextStyle),
                    ]),
            ],
          ),
          IndexedStack(
            index: _step,
            children: <Widget>[
              // 0 - STEP_WEIGHT_INPUT
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Weight (${_si ? "kg" : "lbs"}):", style: _smallerTextStyle),
                  SpinnerInput(
                    spinnerValue: _weight.toDouble(),
                    minValue: 1,
                    maxValue: 800,
                    middleNumberStyle: _largerTextStyle,
                    plusButton: SpinnerButtonStyle(
                      height: _sizeDefault * 2,
                      width: _sizeDefault * 2,
                      child: Icon(Icons.add, size: _sizeDefault * 2 - 10),
                    ),
                    minusButton: SpinnerButtonStyle(
                      height: _sizeDefault * 2,
                      width: _sizeDefault * 2,
                      child: Icon(Icons.remove, size: _sizeDefault * 2 - 10),
                    ),
                    onChange: (newValue) {
                      setState(() {
                        _weight = newValue.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text(
                          _weightInputButtonText(),
                          style: _weightInputButtonTextStyle(),
                        ),
                        style: _weightInputButtonStyle(),
                        onPressed: () async => _onWeightInputButtonPressed,
                      ),
                    ],
                  ),
                ],
              ),
              // 1 - STEP_CALIBRATING
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Target ${descriptor.speedTitle}:", style: _smallerTextStyle),
                  Text("${speedOrPaceString(_targetSpeedHigh, _si, descriptor.sport)}",
                      style: _smallerTextStyle.merge(TextStyle(color: Colors.black54))),
                  Text("Current ${descriptor.speedTitle}:", style: _smallerTextStyle),
                  Text("${speedOrPaceString(_targetSpeedHigh, _si, descriptor.sport)}",
                      style: _smallerTextStyle),
                  Text(_calibrationInstruction(), style: _largerTextStyle),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text(_calibrationButtonText(), style: _smallerTextStyle),
                        onPressed: () async => onCalibrationButtonPressed,
                      ),
                    ],
                  ),
                ],
              ),
              // 2 - STEP_END
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      _calibrationState == CalibrationState.CalibrationSuccess
                          ? "SUCCESS"
                          : "ERROR",
                      style: _largerTextStyle),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text(
                            _calibrationState == CalibrationState.CalibrationSuccess
                                ? 'Close'
                                : 'Retry',
                            style: _smallerTextStyle),
                        onPressed: () {
                          if (_calibrationState == CalibrationState.CalibrationSuccess) {
                            Get.close(1);
                          } else {
                            _step = STEP_WEIGHT_INPUT;
                            _calibrationState = CalibrationState.ReadyToWeighIn;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // 3 - STEP_NOT_SUPPORTED
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  text: TextSpan(
                    text: "${device.name} doesn't seem to support calibration",
                    style: _smallerTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.close(1),
      ),
    );
  }
}