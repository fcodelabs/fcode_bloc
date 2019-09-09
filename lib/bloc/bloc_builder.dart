import 'package:fcode_bloc/bloc/bloc.dart';
import 'package:fcode_bloc/bloc/bloc_provider.dart';
import 'package:fcode_bloc/bloc/default_stream_transformer.dart';
import 'package:fcode_bloc/bloc/ui_model.dart';
import 'package:fcode_bloc/log/log.dart';
import 'package:flutter/material.dart';

class BlocBuilder<B extends BLoC<dynamic, S>, S extends UIModel> extends StatelessWidget {
  final _log = Log("BlocBuilder");
  final Function(BuildContext, S) builder;
  final bool Function(S previous, S current) condition;

  BlocBuilder({
    Key key,
    @required this.builder,
    this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<B>(context);
    S _state = bloc.currentState;

    final streamTransformer = DefaultStreamTransformer.transformer<S, S>(
      handleData: (data, sink) {
        final preState = _state;
        _state = data;
        if (condition?.call(preState, _state) ?? true) {
          sink.add(data);
        }
      },
    );

    return StreamBuilder<S>(
      initialData: _state,
      stream: bloc.stream.transform(streamTransformer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw FlutterError(snapshot.error.toString());
        }
        return builder(context, snapshot.data);
      },
    );
  }
}
