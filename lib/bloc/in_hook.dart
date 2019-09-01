import 'dart:async';

abstract class InHook<Action> {
  final _controller = StreamController<Action>.broadcast();

  InHook(Function(Action) onInput) {
    _controller.stream.listen(onInput);
  }

  void sendInput({Action t}) {
    _controller.add(t);
  }

  void dispose() {
    _controller.close();
  }
}
