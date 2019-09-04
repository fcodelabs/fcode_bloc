import 'dart:async';

class Hook<T> {
  final _controller = StreamController<T>.broadcast();

  void add(T state) {
    _controller.sink.add(state);
  }

  Stream<T> get stream {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
