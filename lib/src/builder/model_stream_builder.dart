import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ModelStreamBuilder<T extends DBModel> extends StatelessWidget {
  final Stream<List<T>> stream;
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

  ModelStreamBuilder({
    Key key,
    @required this.stream,
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
  Widget build(BuildContext context) {
    List<T> preModels = [];
    List<Widget> preChildren = [];

    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error;
        }
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final models = snapshot.data;
        final children = <Widget>[];

        for (int i = 0; i < models.length; i++) {
          final preChild = i < preChildren.length ? preChildren[i] : null;
          if (preChild == null) {
            children.add(builder(context, models[i]));
          } else {
            final preModel = i < preModels.length ? preModels[i] : null;
            if (condition?.call(preModel, models[i]) ?? true) {
              children.add(builder(context, models[i]));
            } else {
              children.add(preChild);
            }
          }
        }
        preChildren = children;
        preModels = models;

        return ListView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          padding: padding,
          primary: primary,
          physics: physics,
          controller: controller,
          dragStartBehavior: dragStartBehavior,
          children: children,
        );
      },
    );
  }
}
