import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db_model.dart';
import '../specification.dart';

typedef MapperCallback<T> = Map<String, dynamic> Function(T item);

abstract class FirebaseRepository<T extends DBModel> {
  T fromSnapshot(DocumentSnapshot snapshot);

  Map<String, dynamic> toMap(T item);

  CollectionReference _merge(String type, DocumentReference parent) {
    assert(parent != null || type != null);
    return parent?.collection(type) ?? Firestore.instance.collection(type);
  }

  Future<void> add({
    @required T item,
    @required String type,
    DocumentReference parent,
  }) async {
    assert(item != null);
    final data = toMap(item);
    if (item.ref == null) {
      item.ref = _merge(type, parent).document(item.id);
    }
    item.ref.setData(data);
  }

  Future<void> addList({
    @required Iterable<T> items,
    @required String type,
    DocumentReference parent,
  }) async {
    final futures = items.map(
      (item) => add(
        item: item,
        type: type,
        parent: parent,
      ),
    );
    await Future.wait(futures);
  }

  Stream<List<T>> query({
    @required SpecificationI specification,
    @required String type,
    DocumentReference parent,
  }) {
    assert(specification != null);
    final stream = specification.specify(_merge(type, parent));
    return stream.map<List<T>>((data) {
      final items = <T>[];
      for (final document in data) {
        final item = fromSnapshot(document);
        if (item != null) {
          items.add(item);
        }
      }
      return items;
    });
  }

  Future<List<T>> querySingle({
    @required SpecificationI specification,
    @required String type,
    DocumentReference parent,
  }) async {
    assert(specification != null);
    final snapshots = await specification.specifySingle(_merge(type, parent));
    final items = <T>[];
    for (final snapshot in snapshots) {
      final item = fromSnapshot(snapshot);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  Future<void> remove({@required T item}) async {
    assert(item != null);
    await item.ref?.delete();
  }

  Future<void> removeList({
    @required SpecificationI specification,
    @required String type,
    DocumentReference parent,
  }) async {
    assert(specification != null);
    final data = await specification.specifySingle(_merge(type, parent));
    final futures = data.map((item) => item.reference.delete());
    await Future.wait(futures);
  }

  Future<void> update({
    @required T item,
    @required String type,
    DocumentReference parent,
    MapperCallback<T> mapper,
  }) async {
    assert(item != null);
    final data = mapper?.call(item) ?? toMap(item);
    if (item.ref == null) {
      return add(item: item, type: type, parent: parent);
    }
    return item.ref.updateData(data);
  }
}
