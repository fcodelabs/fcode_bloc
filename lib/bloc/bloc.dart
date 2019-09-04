import 'package:fcode_mvp/bloc/hook.dart';
import 'package:fcode_mvp/bloc/ui_model.dart';
import 'package:fcode_mvp/log/log.dart';

abstract class BLoC<Action, State extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = Hook<Action>();
  final _outHook = Hook<State>();
  State currentState;

  BLoC() {
    currentState = initState;
    _inHook.stream.listen((action) {
      currentState = mapActionToState(action, currentState.clone());
      _outHook.add(currentState);
    });
  }

  void dispose() {
    _inHook.dispose();
    _outHook.dispose();
  }

  State mapActionToState(Action action, State preState);

  State get initState;

  void dispatch(Action action) {
    _inHook.add(action);
  }

  Stream<State> get stream => _outHook.stream;
}
