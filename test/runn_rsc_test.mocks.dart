// Mocks generated by Mockito 5.0.17 from annotations
// in track_my_indoor_exercise/test/runn_rsc_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:flutter_blue/flutter_blue.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeDeviceIdentifier_0 extends _i1.Fake implements _i2.DeviceIdentifier {}

/// A class which mocks [BluetoothDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothDevice extends _i1.Mock implements _i2.BluetoothDevice {
  MockBluetoothDevice() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeviceIdentifier get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: _FakeDeviceIdentifier_0())
          as _i2.DeviceIdentifier);
  @override
  String get name => (super.noSuchMethod(Invocation.getter(#name), returnValue: '') as String);
  @override
  _i2.BluetoothDeviceType get type =>
      (super.noSuchMethod(Invocation.getter(#type), returnValue: _i2.BluetoothDeviceType.unknown)
          as _i2.BluetoothDeviceType);
  @override
  _i3.Stream<bool> get isDiscoveringServices =>
      (super.noSuchMethod(Invocation.getter(#isDiscoveringServices),
          returnValue: Stream<bool>.empty()) as _i3.Stream<bool>);
  @override
  _i3.Stream<List<_i2.BluetoothService>> get services =>
      (super.noSuchMethod(Invocation.getter(#services),
              returnValue: Stream<List<_i2.BluetoothService>>.empty())
          as _i3.Stream<List<_i2.BluetoothService>>);
  @override
  _i3.Stream<_i2.BluetoothDeviceState> get state => (super.noSuchMethod(Invocation.getter(#state),
          returnValue: Stream<_i2.BluetoothDeviceState>.empty())
      as _i3.Stream<_i2.BluetoothDeviceState>);
  @override
  _i3.Stream<int> get mtu =>
      (super.noSuchMethod(Invocation.getter(#mtu), returnValue: Stream<int>.empty())
          as _i3.Stream<int>);
  @override
  _i3.Future<bool> get canSendWriteWithoutResponse =>
      (super.noSuchMethod(Invocation.getter(#canSendWriteWithoutResponse),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<void> connect({Duration? timeout, bool? autoConnect = true}) => (super.noSuchMethod(
      Invocation.method(#connect, [], {#timeout: timeout, #autoConnect: autoConnect}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<dynamic> disconnect() =>
      (super.noSuchMethod(Invocation.method(#disconnect, []), returnValue: Future<dynamic>.value())
          as _i3.Future<dynamic>);
  @override
  _i3.Future<List<_i2.BluetoothService>> discoverServices() =>
      (super.noSuchMethod(Invocation.method(#discoverServices, []),
              returnValue: Future<List<_i2.BluetoothService>>.value(<_i2.BluetoothService>[]))
          as _i3.Future<List<_i2.BluetoothService>>);
  @override
  _i3.Future<void> requestMtu(int? desiredMtu) =>
      (super.noSuchMethod(Invocation.method(#requestMtu, [desiredMtu]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
}
