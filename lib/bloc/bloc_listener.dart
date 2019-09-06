typedef BlocListener<T> = Function(BlocSnapshot<T> snapshot);

class BlocSnapshot<T> {
  final T data;
  final Object error;
  final StackTrace stackTrace;

  BlocSnapshot._(this.data, this.error, this.stackTrace);

  BlocSnapshot.fromData(T data) : this._(data, null, null);

  BlocSnapshot.fromError(Object error, [stacktrace]) : this._(null, error, stacktrace);

  bool get hasError => error != null;

  bool get hasData => data != null;

  @override
  String toString() => '$runtimeType($data, $error, $stackTrace)';
}
