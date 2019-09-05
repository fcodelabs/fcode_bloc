import 'package:fcode_mvp/bloc/hook.dart';
import 'package:fcode_mvp/bloc/ui_model.dart';
import 'package:fcode_mvp/log/log.dart';

abstract class BLoC<Action, State extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = Hook<Action>();
  final _outHook = Hook<State>();
  State currentState;
  Action currentAction;

  BLoC() {
    currentState = initState;
    _inHook.stream.asyncExpand((action) {
      currentAction = action;
      return mapActionToState(action);
    }).forEach((state) {
      currentState = state;
      _outHook.add(state);
    });
  }

  void dispose() {
    _inHook.dispose();
    _outHook.dispose();
  }

  Stream<State> mapActionToState(Action action);

  State get initState;

  void dispatch(Action action) {
    _inHook.add(action);
  }

  Stream<State> get stream => _outHook.stream;
}
