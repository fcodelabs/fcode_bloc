import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DBModel {
  DocumentReference ref;

  DBModel({this.ref});

  @override
  bool operator ==(Object other) {
    if (other is DBModel) {
      return other.ref?.path == this.ref?.path;
    }
    return false;
  }

  @override
  int get hashCode {
    return ref?.hashCode ?? 0;
  }

  @override
  String toString() {
    return "Reference: ${ref?.path}";
  }

  DBModel clone() {
    return this;
  }

  String get id => ref?.documentID;
}
