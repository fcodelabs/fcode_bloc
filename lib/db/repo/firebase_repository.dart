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

  Stream<T> query({@required SpecificationI specification, @required String type, DocumentReference parent}) async* {
    parent = parent ?? Firestore.instance;
    final stream = specification.specify(parent.collection(type));
    await for (final snapshot in stream) {
      final item = fromSnapshot(snapshot);
      if (item != null) {
        yield item;
      }
    }
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

