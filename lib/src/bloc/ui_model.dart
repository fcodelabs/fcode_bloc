import 'package:flutter/material.dart';

@immutable
abstract class UIModel {
  UIModel clone();

  @mustCallSuper
  void dispose() {}
}
