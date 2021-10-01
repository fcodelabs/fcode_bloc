import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/db_model_i.dart';
import '../spec/firebase/firebase_specification.dart';
import '../spec/specification.dart';

/// Map an [DBModel] to a [Map<String, dynamic> so that
/// Firestore can understand which fields to be updated.
/// Put only fields that's needed to be updated in the
/// returning [Map].
typedef MapperCallback<T> = Map<String, dynamic> Function(T item);

/// {@template repo}
/// A repository that can be used to add, query, update and delete
/// document from Firestore.
///
/// Should implement [FirebaseRepository.fromSnapshot] and
/// [FirebaseRepository.toMap] to work with the given type of [DBModel]
/// {@endtemplate}
abstract class FirebaseRepository<T extends DBModelI> {
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Returns a [T] (of [DBModel]) when a [snapshot] is given.
  /// Can return null if the [snapshot] is in bad format.
  ///
  /// If it is going to return a [DBModel], [DBModel.ref] should always
  /// be not `null`.
  T fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  /// Converts the given [item] to a [Map] that can be stored in
  /// Firestore.
  Map<String, Object?> toMap(
    T value,
    SetOptions? options,
  );

  _merge(String type, DocumentReference? parent) {
    return parent?.collection(type) ??
        FirebaseFirestore.instance.collection(type);
  }

  Stream<Iterable<T>> _query2stream(FirebaseSpecificationI<T> spec, Query query) {
    final q = query.withConverter(
      fromFirestore: fromSnapshot,
      toFirestore: toMap,
    );
    return spec.specify(q);
  }

  Future<Iterable<T>> _query2future(
    FirebaseSpecificationI<T> spec,
    Query query,
  ) async {
    final q = query.withConverter(
      fromFirestore: fromSnapshot,
      toFirestore: toMap,
    );
    return await spec.specifySingle(q);
  }

  /// Given [item] will be added to the collection with name [type],
  /// which is inside the document [parent]. If [parent] is null,
  /// global collection with name [type] will be used to store the [item].
  ///
  /// Will return the [DocumentReference] that was used to store [item].
  Future<DocumentReference> add({
    required T item,
    SetOptions? setOptions,
    required String type,
    DocumentReference? parent,
  }) async {
    final data = toMap(item, setOptions);
    final ref = _merge(type, parent).doc(item.id);
    if (await _checkConnectivity()) {
      await ref.set(data);
    } else {
      ref.set(data);
    }
    return ref;
  }

  /// Same as [FirebaseRepository.add] but will store a [Iterable] of given
  /// [items] and return a [Iterable] of [DocumentReference]s.
  Future<void> addList({
    required Iterable<T> items,
    required String type,
    DocumentReference? parent,
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

  /// Query some data from a Firestore collection with name [type] in the
  /// document with [DocumentReference] [parent] according to the
  /// given rule in the [specification].
  ///
  /// Will return a [Stream] of [Iterable] with items. The stream will emmit
  /// values each time specified documents in the Firestore get
  /// updated.
  ///
  /// Eg:
  ///
  /// This code will query all the documents in the
  /// global collection `People` in Firestore.
  /// ```dart
  /// peopleRepository.query(
  ///   specification: ComplexSpecification([]),
  ///   type: 'People',
  ///   parent: null,
  /// );
  /// ```
  ///
  /// This will query for documents with name `Hilda` in the
  /// same collection.
  /// ```dart
  /// peopleRepository.query(
  ///   specification: ComplexSpecification([
  ///     ComplexWhere('name', isEqualTo: 'Hilda'),
  ///   ]),
  ///   type: 'People',
  ///   parent: null,
  /// );
  /// ```
  Stream<Iterable<T>> query({
    required SpecificationI specification,
    required String type,
    DocumentReference? parent,
  }) {
    final spec = specification as FirebaseSpecificationI<T>;
    return _query2stream(spec, _merge(type, parent));
  }

  /// Usage is as same as in the [FirebaseRepository.query], but this is
  /// for collection group querying.
  ///
  /// This function will return a [Stream] of [Iterable]s with data from the
  /// specified collection group.
  ///
  /// You can find more about the collection groups in the official
  /// firebase documentation.
  ///
  /// https://firebase.google.com/docs/firestore/query-data/queries#collection-group-query
  Stream<Iterable<T>> queryGroup({
    required SpecificationI specification,
    required String collectionPath,
  }) {
    final spec = specification as FirebaseSpecificationI<T>;
    return _query2stream(
      spec,
      FirebaseFirestore.instance.collectionGroup(collectionPath),
    );
  }

  /// Same as [FirebaseRepository.query] but instead of returning a [Stream]
  /// this will return a [Future] with the latest values in the Firestore.
  ///
  /// Usage is as same as the example in [FirebaseRepository.query]
  Future<Iterable<T>> querySingle({
    required SpecificationI specification,
    required String type,
    DocumentReference? parent,
  }) async {
    final spec = specification as FirebaseSpecificationI<T>;
    return _query2future(spec, _merge(type, parent));
  }

  /// Same as [FirebaseRepository.queryGroup] but instead of returning a
  /// [Stream] this will return a [Future] with the latest values
  /// in the Firestore.
  ///
  /// Usage is as same as the example in [FirebaseRepository.query]
  /// and [FirebaseRepository.queryGroup]
  Future<Iterable<T>> queryGroupSingle({
    required SpecificationI specification,
    required String collectionPath,
  }) async {
    final spec = specification as FirebaseSpecificationI<T>;
    return _query2future(
      spec,
      FirebaseFirestore.instance.collectionGroup(collectionPath),
    );
  }

  /// Delete the document corresponding to the [item].
  /// If the reference of the [item] ([DBModel.ref]) is null
  /// nothing will happen.
  Future<void> remove({required T item}) async {
    if (await _checkConnectivity()) {
      await item.ref?.delete();
    } else {
      item.ref?.delete();
    }
  }

  /// Deletes a set of documents in the collection named [type] which is
  /// inside the [parent] document. If [parent] is `null`, a global
  /// collection with named [type] will be used.
  ///
  /// The set of documents to be deleted is selected by the given
  /// [specification]. To learn how to use [SpecificationI] look at the
  /// examples in [FirebaseRepository.query].
  Future<void> removeList({
    required SpecificationI specification,
    required String type,
    DocumentReference? parent,
  }) async {
    final spec = specification as FirebaseSpecificationI<T>;
    final data = await spec.specifySingle(_merge(type, parent));
    final futures = data.map((item) async => item.ref?.delete());
    if (await _checkConnectivity()) {
      await Future.wait(futures);
    } else {
      Future.wait(futures);
    }
  }

  /// Update the document which is corresponding to the given [item].
  ///
  /// Firestore allows you to update only some fields instead of rewriting
  /// the whole document. The [mapper] function is used map the [item]
  /// to a [Map] with only the required fields to be updated.
  ///
  /// If [mapper] is `null` [FirebaseRepository.toMap] will be used to
  /// map the [item]. In this case, the whole document will be rewritten.
  ///
  /// [type] and [parent] can be null if the [item] has a valid
  /// [DocumentReference] as [DBModel.ref]. If reference is `null` a
  /// new [item] will be created in the database with [FirebaseRepository.add].
  ///
  /// Returns the [DocumentReference] which was used to update
  /// or add the [item].
  Future<DocumentReference> update({
    required T item,
    SetOptions? setOptions,
    required String type,
    DocumentReference? parent,
    MapperCallback<T>? mapper,
  }) async {
    final data = mapper?.call(item) ?? toMap(item, setOptions);
    if (item.ref == null) {
      return await add(item: item, type: type, parent: parent);
    }
    if (await _checkConnectivity()) {
      await item.ref!.update(data);
    } else {
      item.ref!.update(data);
    }
    return item.ref!;
  }
}
