import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_mvp/db/db_model.dart';
import 'package:fcode_mvp/fcode_mvp.dart';
import 'package:flutter/material.dart';

abstract class FirebaseRepository<T extends DBModel> {

  T fromSnapshot(DocumentSnapshot snapshot);

  Map<String, dynamic> toMap(T item);

  Future<void> add({@required T item, @required String type, DocumentReference parent}) async {
    parent = parent ?? Firestore.instance;
    final data = toMap(item);
    if (item.ref == null) {
      item.ref = parent.collection(type).document();
    }
    item.ref.setData(data);
  }

  Future<void> addList({@required Iterable<T> items, @required String type, DocumentReference parent}) async {
    for (final item in items) {
      await add(item: item, type: type, parent: parent);
    }
  }

  Future<List<T>> query(SpecificationI specification) async {
//    final firebaseSpecification = specification as FirebaseSpecification;
//    final List<DocumentSnapshot> snapshots =
//    await firebaseSpecification.specify(parent.collection(DBUtils.TEST));
//    final List<Test> tests = [];
//    for (final snapshot in snapshots) {
//      final test = fromSnapshot(snapshot);
//      if (test == null) {
//        continue;
//      }
//      tests.add(test);
//    }
//    return tests;
  }

  Future<void> remove(T item) async {
    // TODO: implement remove
  }

  Future<void> removeList(SpecificationI specification) async {
    // TODO: implement removeList
  }

  Future<void> update({@required T item, @required String type, DocumentReference parent}) async {
    final data = toMap(item);
    if (item.ref == null) {
      return add(item: item, type: type, parent: parent);
    }
    return item.ref.updateData(data);
  }
}

