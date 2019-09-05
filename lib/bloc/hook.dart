import 'dart:async';

class Hook<T> {
  // ToDo: Remove hook and use RxDart package
  final _controller = StreamController<T>.broadcast();

  void add(T state) {
    _controller.sink.add(state);
  }

  Stream<T> get stream {
    return _controller.stream;
  }

  StreamSink<T> get sink {
    return _controller.sink;
  }

  void pipe(Hook<T> hook) {
    stream.pipe(hook.sink);
  }

  void dispose() {
    _controller.close();
  }
}
