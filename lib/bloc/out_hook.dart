import 'dart:async';

class OutHook<State> {
  final _controller = StreamController<State>.broadcast();

  OutHook();

  Stream<State> outputStream() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
