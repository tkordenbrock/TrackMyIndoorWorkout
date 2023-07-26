// Mocks generated by Mockito 5.4.2 from annotations
// in track_my_indoor_exercise/test/infer_sport_from_characteristics_id_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDeviceIdentifier_0 extends _i1.SmartFake implements _i2.DeviceIdentifier {
  _FakeDeviceIdentifier_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BluetoothDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothDevice extends _i1.Mock implements _i2.BluetoothDevice {
  @override
  _i2.DeviceIdentifier get remoteId => (super.noSuchMethod(
        Invocation.getter(#remoteId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  String get localName => (super.noSuchMethod(
        Invocation.getter(#localName),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i2.BluetoothDeviceType get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: _i2.BluetoothDeviceType.unknown,
        returnValueForMissingStub: _i2.BluetoothDeviceType.unknown,
      ) as _i2.BluetoothDeviceType);
  @override
  _i3.Stream<bool> get isDiscoveringServices => (super.noSuchMethod(
        Invocation.getter(#isDiscoveringServices),
        returnValue: _i3.Stream<bool>.empty(),
        returnValueForMissingStub: _i3.Stream<bool>.empty(),
      ) as _i3.Stream<bool>);
  @override
  _i3.Stream<List<_i2.BluetoothService>> get servicesStream => (super.noSuchMethod(
        Invocation.getter(#servicesStream),
        returnValue: _i3.Stream<List<_i2.BluetoothService>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<_i2.BluetoothService>>.empty(),
      ) as _i3.Stream<List<_i2.BluetoothService>>);
  @override
  _i3.Stream<_i2.BluetoothConnectionState> get connectionState => (super.noSuchMethod(
        Invocation.getter(#connectionState),
        returnValue: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
      ) as _i3.Stream<_i2.BluetoothConnectionState>);
  @override
  _i3.Stream<int> get mtu => (super.noSuchMethod(
        Invocation.getter(#mtu),
        returnValue: _i3.Stream<int>.empty(),
        returnValueForMissingStub: _i3.Stream<int>.empty(),
      ) as _i3.Stream<int>);
  @override
  _i2.DeviceIdentifier get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#id),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#id),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i3.Stream<_i2.BluetoothConnectionState> get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
      ) as _i3.Stream<_i2.BluetoothConnectionState>);
  @override
  _i3.Stream<List<_i2.BluetoothService>> get services => (super.noSuchMethod(
        Invocation.getter(#services),
        returnValue: _i3.Stream<List<_i2.BluetoothService>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<_i2.BluetoothService>>.empty(),
      ) as _i3.Stream<List<_i2.BluetoothService>>);
  @override
  _i3.Future<void> connect({
    Duration? timeout = const Duration(seconds: 15),
    bool? autoConnect = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #connect,
          [],
          {
            #timeout: timeout,
            #autoConnect: autoConnect,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> disconnect({int? timeout = 15}) => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<List<_i2.BluetoothService>> discoverServices({int? timeout = 15}) =>
      (super.noSuchMethod(
        Invocation.method(
          #discoverServices,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<List<_i2.BluetoothService>>.value(<_i2.BluetoothService>[]),
        returnValueForMissingStub:
            _i3.Future<List<_i2.BluetoothService>>.value(<_i2.BluetoothService>[]),
      ) as _i3.Future<List<_i2.BluetoothService>>);
  @override
  _i3.Future<int> requestMtu(
    int? desiredMtu, {
    int? timeout = 15,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestMtu,
          [desiredMtu],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<int>.value(0),
        returnValueForMissingStub: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);
  @override
  _i3.Future<int> readRssi({int? timeout = 15}) => (super.noSuchMethod(
        Invocation.method(
          #readRssi,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<int>.value(0),
        returnValueForMissingStub: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);
  @override
  _i3.Future<void> requestConnectionPriority(
          {required _i2.ConnectionPriority? connectionPriorityRequest}) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestConnectionPriority,
          [],
          {#connectionPriorityRequest: connectionPriorityRequest},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> setPreferredPhy({
    required int? txPhy,
    required int? rxPhy,
    required _i2.PhyCoding? option,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPreferredPhy,
          [],
          {
            #txPhy: txPhy,
            #rxPhy: rxPhy,
            #option: option,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> pair() => (super.noSuchMethod(
        Invocation.method(
          #pair,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> clearGattCache() => (super.noSuchMethod(
        Invocation.method(
          #clearGattCache,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<bool> removeBond() => (super.noSuchMethod(
        Invocation.method(
          #removeBond,
          [],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
