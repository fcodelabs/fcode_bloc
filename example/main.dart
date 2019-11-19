import 'package:fcode_bloc/fcode_bloc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        builder: (context) => ExamplePageBloc(),
        child: ExamplePageView(),
      ),
    );
  }
}

class ExamplePageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final examplePageBloc = BlocProvider.of<ExamplePageBloc>(context);
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            BlocBuilder<ExamplePageBloc, ExamplePageModel>(
              condition: (pre, current) => pre.count != current.count,
              builder: (context, state) {
                return Text("COUNT: ${state.count}");
              },
            ),
            RaisedButton(
              onPressed: () => examplePageBloc.add(IncrementAction()),
              child: Text("Increment"),
            ),
            RaisedButton(
              onPressed: () => examplePageBloc.add(SubtractAction(3)),
              child: Text("Subtract 3"),
            ),
            RaisedButton(
              onPressed: () => examplePageBloc.add(SubtractAction(5)),
              child: Text("Subtract 5"),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamplePageBloc extends BLoC<ExamplePageAction, ExamplePageModel> {
  @override
  ExamplePageModel get initialState => ExamplePageModel(
        count: 0,
      );

  @override
  Stream<ExamplePageModel> mapEventToState(ExamplePageAction action) async* {
    switch (action.runtimeType) {
      case IncrementAction:
        yield state.clone(
          count: state.count + 1,
        );
        break;

      case SubtractAction:
        yield state.clone(
          count: state.count - (action as SubtractAction).value,
        );
        break;
    }
  }
}

class ExamplePageModel extends UIModel {
  final int count;

  ExamplePageModel({@required this.count});

  @override
  UIModel clone({int count}) {
    return ExamplePageModel(
      count: count ?? this.count,
    );
  }
}

@immutable
abstract class ExamplePageAction {}

class IncrementAction extends ExamplePageAction {}

class SubtractAction extends ExamplePageAction {
  final int value;

  SubtractAction(this.value);
}
