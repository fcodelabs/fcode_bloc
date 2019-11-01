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

  @override
  void initState() {
    super.initState();
    _state = widget.model;
    _subscribe();
  }

  @override
  void didUpdateWidget(ModelBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository && handler != null) {
      handler.repository = widget.repository;
    }
    if (oldWidget.model != widget.model) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    handler = ReferenceHandler<T>(repository: widget.repository, reference: widget.model.ref);
    handler.initialize();
    handler.addListener((state) {
      if (widget.condition?.call(_state, state) ?? true) {
        setState(() {
          _state = state;
        });
      }
    });
  }

  void _unsubscribe() {
    handler?.close();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);
}
