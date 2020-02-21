import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/specification.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
    for (final item in items) {
      await add(item: item, type: type, parent: parent);
    }
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
    snapshots.forEach((snapshot) {
      final item = fromSnapshot(snapshot);
      if (item != null) {
        items.add(item);
      }
    });
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
    final data = await specification.specify(_merge(type, parent)).first;
    for (final item in data) {
      await item.reference.delete();
    }
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

  Stream<T> transform({
    @required DocumentReference ref,
  }) {
    return ref.snapshots().map<T>((snapshot) {
      return fromSnapshot(snapshot);
    });
  }

  Future<T> fetch({
    @required DocumentReference ref,
  }) async {
    final snapshot = await ref.get();
    return fromSnapshot(snapshot);
  }

  Stream<List<T>> multiTransform({
    @required Iterable<DocumentReference> refs,
  }) {
    return ZipStream.list(refs.map<Stream<T>>(
      (ref) => transform(ref: ref),
    ));
  }

  static Future<void> arrayUpdate({
    @required DocumentReference ref,
    @required String field,
    @required List<dynamic> values,
    bool add = true,
  }) async {
    assert(ref != null);
    assert(field?.isNotEmpty ?? false);
    assert(values?.isNotEmpty ?? false);
    if (add) {
      return await ref.updateData({
        field: FieldValue.arrayUnion(values),
      });
    } else {
      return await ref.updateData({
        field: FieldValue.arrayRemove(values),
      });
    }
  }

  static Future<Map<String, dynamic>> runTransaction({
    @required TransactionHandler transactionHandler,
    Duration timeout,
  }) async {
    return await Firestore.instance.runTransaction(
      transactionHandler,
      timeout: timeout,
    );
  }

  static WriteBatch getBatch() {
    return Firestore.instance.batch();
  }
}
