import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/power_tune.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';

class PowerFactorTuneBottomSheet extends StatefulWidget {
  final String deviceId;
  final double powerFactor;

  PowerFactorTuneBottomSheet({Key key, @required this.deviceId, @required this.powerFactor})
      : assert(deviceId != null),
        assert(powerFactor != null),
        super(key: key);

  @override
  PowerFactorTuneBottomSheetState createState() =>
      PowerFactorTuneBottomSheetState(deviceId: deviceId, oldPowerFactor: powerFactor);
}

class PowerFactorTuneBottomSheetState extends State<PowerFactorTuneBottomSheet> {
  PowerFactorTuneBottomSheetState({@required this.deviceId, @required this.oldPowerFactor})
      : assert(deviceId != null),
        assert(oldPowerFactor != null);

  final String deviceId;
  final double oldPowerFactor;
  double _powerFactorPercent;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;

  @override
  void initState() {
    super.initState();

    _powerFactorPercent = oldPowerFactor * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 10;
      _selectedTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
      _largerTextStyle = _selectedTextStyle.apply(color: Colors.black);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Power Factor %", style: _largerTextStyle),
            SpinBox(
              min: 1,
              max: 1000,
              value: _powerFactorPercent,
              onChanged: (value) => _powerFactorPercent = value,
              textStyle: _largerTextStyle,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        child: Icon(Icons.check),
        onPressed: () async {
          final database = Get.find<AppDatabase>();
          final powerFactor = _powerFactorPercent / 100.0;
          if (await database?.hasPowerTune(deviceId) ?? false) {
            var powerTune = await database?.powerTuneDao?.findPowerTuneByMac(deviceId)?.first;
            powerTune.powerFactor = powerFactor;
            await database?.powerTuneDao?.updatePowerTune(powerTune);
          } else {
            final powerTune = PowerTune(mac: deviceId, powerFactor: powerFactor);
            await database?.powerTuneDao?.insertPowerTune(powerTune);
          }
          Get.back(result: powerFactor);
        },
      ),
    );
  }
}
