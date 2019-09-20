import 'dart:async';

import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/reference_handler.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/material.dart';

class ModelBuilder<T extends DBModel> extends StatelessWidget {
  final T model;
  final FirebaseRepository<T> repository;
  final Widget Function(BuildContext, T) builder;
  final bool Function(T previous, T current) condition;

  ModelBuilder({Key key, @required this.model, @required this.repository, @required this.builder, this.condition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final handler = ReferenceHandler<T>(repository: repository, model: model);
    T _state = model;

    final streamTransformer = StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) {
        final preState = _state;
        final currentState = data;
        if (condition?.call(preState, currentState) ?? true) {
          _state = data;
          sink.add(data);
        }
      },
    );

    return StreamBuilder<T>(
      initialData: model,
      stream: handler.stream.transform(streamTransformer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw FlutterError(snapshot.error.toString());
        }
        return builder(context, snapshot.data);
      },
    );
  }
}
