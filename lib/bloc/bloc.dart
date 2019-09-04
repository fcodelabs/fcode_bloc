import 'package:fcode_mvp/bloc/hook.dart';
import 'package:fcode_mvp/bloc/ui_model.dart';

abstract class BLoC<Action, State extends UIModel> {
  final _inHook = Hook<Action>();
  final _outHook = Hook<State>();
  State state;

  BLoC() {
    state = initState;
    _inHook.stream.listen((action) {
      state = mapActionToState(action);
      _outHook.add(state);
    });
  }

  void dispose() {
    _inHook.dispose();
    _outHook.dispose();
  }

  State mapActionToState(Action action);

  State get initState;

  void dispatch(Action action) {
    _inHook.add(action);
  }

  Stream<State> get stream => _outHook.stream;
}
