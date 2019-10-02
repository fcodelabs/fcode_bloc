import 'package:flutter/material.dart';

typedef BlocListener<A, S> = void Function(BlocSnapshot<A, S> snapshot);

@immutable
class BlocSnapshot<A, S> {
  final S data;
  final S preData;
  final A action;
  final Object error;
  final StackTrace stacktrace;

  BlocSnapshot._(this.data, this.preData, this.action, this.error, this.stacktrace);

  BlocSnapshot.fromData(S data, S preData) : this._(data, preData, null, null, null);

  BlocSnapshot.fromAction(A action) : this._(null, null, action, null, null);

  BlocSnapshot.fromError(Object error, [stacktrace]) : this._(null, null, null, error, stacktrace);

  bool get hasError => error != null;

  bool get hasData => data != null;

  bool get hasAction => action != null;

  @override
  String toString() => '$runtimeType($data, $error, $stacktrace)';
}
