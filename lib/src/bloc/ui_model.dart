import 'package:flutter/material.dart';

abstract class UIModel {
  UIModel clone();

  @mustCallSuper
  void dispose() {}
}
