import 'package:fcode_bloc/src/builder/model_builder.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MultiModelBuilder<T extends DBModel> extends StatelessWidget {
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

  MultiModelBuilder({
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
  Widget build(BuildContext context) {
    final children = models.map<ModelBuilder>((model) {
      return ModelBuilder(
        key: key,
        repository: repository,
        model: model,
        condition: condition,
        builder: builder,
      );
    }).toList(growable: false);

    final widget = scrollDirection == Axis.vertical
        ? Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          )
        : Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );

    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      padding: padding,
      primary: primary,
      physics: physics,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      child: widget,
    );
  }
}
