import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class DBModel {
  DocumentReference ref;

  DBModel({this.ref});

  @override
  bool operator ==(other) {
    if (other is DBModel) {
      return other.ref.path == this.ref.path;
    }
    return false;
  }

  @override
  int get hashCode {
    return ref.hashCode;
  }

  @override
  String toString() {
    return "Reference: " + ref.path;
  }

  DBModel clone() {
    return this;
  }

  @mustCallSuper
  void dispose(){}

  String get id => ref?.documentID;
}
