import 'dart:async';

import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/reference_handler.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/material.dart';

class ModelBuilder<T extends DBModel> extends StatefulWidget {
  final T model;
  final FirebaseRepository<T> repository;
  final Widget Function(BuildContext, T) builder;
  final bool Function(T previous, T current) condition;

  ModelBuilder({Key key, @required this.model, @required this.repository, @required this.builder, this.condition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModelBuilderState();

}

class _ModelBuilderState<T extends DBModel> extends State<ModelBuilder<T>> {
  T _state;
  ReferenceHandler handler;
  StreamTransformer streamTransformer;

  @override
  void initState() {
    super.initState();
    _state = widget.model;
    handler = ReferenceHandler<T>(repository: widget.repository, model: widget.model);
    streamTransformer = StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) {
        final preState = _state;
        final currentState = data;
        if (widget.condition?.call(preState, currentState) ?? true) {
          _state = data;
          sink.add(data);
        }
      },
    );
  }

  @override
  void didUpdateWidget(ModelBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      handler.repository = widget.repository;
    }
    if (oldWidget.model != widget.model) {
      handler.dispose();
      handler = ReferenceHandler<T>(repository: widget.repository, model: widget.model);
    }
  }

  @override
  void dispose() {
    handler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: widget.model,
      stream: handler.stream.transform(streamTransformer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error;
        }
        return widget.builder(context, snapshot.data);
      },
    );
  }
}
