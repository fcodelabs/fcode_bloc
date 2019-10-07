import 'dart:collection';

import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ModelListBuilder<T extends DBModel> extends StatefulWidget {
  final List<T> models;
  final Widget Function(BuildContext context, T model) builder;
  final bool Function(T previous, T current) condition;
  final FirebaseRepository<T> repository;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry padding;
  final bool primary;
  final ScrollPhysics physics;
  final ScrollController controller;
  final DragStartBehavior dragStartBehavior;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  ModelListBuilder({
    Key key,
    @required this.models,
    @required this.repository,
    @required this.builder,
    this.condition,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModelListBuilderState();
}

class _ModelListBuilderState<T extends DBModel> extends State<ModelListBuilder<T>> {
  HashSet<T> preModels = HashSet();
  List<Widget> preChildren = [];

  @override
  Widget build(BuildContext context) {
    final children = List<Widget>(preChildren?.length ?? 10);
    final models = widget.models;

    for (int i = 0; i < models.length; i++) {
      final preChild = i < preChildren.length ? preChildren[i] : null;
      if (preChild == null) {
        children.add(widget.builder(context, models[i]));
      } else {
        final model = models[i];
        if (preModels.contains(model)) {
          children.add(preChild);
        } else {
          final preModel = i < preModels.length ? preModels.elementAt(i) : null;
          if (widget.condition?.call(preModel, models[i]) ?? true) {
            children.add(widget.builder(context, models[i]));
          } else {
            children.add(preChild);
          }
        }
      }
    }
    preChildren = children;
    preModels = HashSet.from(models);

    return ListView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      primary: widget.primary,
      physics: widget.physics,
      controller: widget.controller,
      dragStartBehavior: widget.dragStartBehavior,
      children: children,
    );
  }
}
