import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/db_model_i.dart';
import '../spec/query_transformer.dart';

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
  /// Name of the collection or the sub collection that this repository
  /// is accessing.
  final String type;

  /// {@macro repo}
  FirebaseRepository(this.type);

  static Future<bool> _checkConnectivity() async {
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

  _merge(DocumentReference? parent) {
    return parent?.collection(type) ??
        FirebaseFirestore.instance.collection(type);
  }

  Stream<Iterable<T>> _query2stream(
      Query query, QueryTransformer qt, bool includeMetadataChanges) {
    return qt
        .transform(query)
        .withConverter(fromFirestore: fromSnapshot, toFirestore: toMap)
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((data) => data.docs.map((e) => e.data()));
  }

  Future<Iterable<T>> _query2future(
      Query query, QueryTransformer qt, Source source) async {
    final q = await qt
        .transform(query)
        .withConverter(
          fromFirestore: fromSnapshot,
          toFirestore: toMap,
        )
        .get(GetOptions(source: source));
    return q.docs.map((e) => e.data());
  }

  /// Given [item] will be added to the collection with name [type],
  /// which is inside the document [parent]. If [parent] is null,
  /// global collection with name [type] will be used to store the [item].
  ///
  /// Will return the [DocumentReference] that was used to store [item].
  Future<DocumentReference> add({
    required T item,
    SetOptions? setOptions,
    DocumentReference? parent,
  }) async {
    final data = toMap(item, setOptions);
    final ref = _merge(parent).doc(item.id);
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
    DocumentReference? parent,
  }) async {
    final futures = items.map(
      (item) => add(
        item: item,
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
  /// peopleRepository = PeopleRepository('People');
  /// peopleRepository.query(
  ///   specification: ComplexSpecification([]),
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
    required QueryTransformer spec,
    DocumentReference? parent,
    bool includeMetadataChanges = false,
  }) {
    return _query2stream(_merge(parent), spec, includeMetadataChanges);
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
    required QueryTransformer spec,
    required String collectionPath,
    bool includeMetadataChanges = false,
  }) {
    return _query2stream(
      FirebaseFirestore.instance.collectionGroup(collectionPath),
      spec,
      includeMetadataChanges,
    );
  }

  /// Same as [FirebaseRepository.query] but instead of returning a [Stream]
  /// this will return a [Future] with the latest values in the Firestore.
  ///
  /// Usage is as same as the example in [FirebaseRepository.query]
  Future<Iterable<T>> querySingle({
    required QueryTransformer spec,
    DocumentReference? parent,
    Source source = Source.serverAndCache,
  }) async {
    return _query2future(_merge(parent), spec, source);
  }

  /// Same as [FirebaseRepository.queryGroup] but instead of returning a
  /// [Stream] this will return a [Future] with the latest values
  /// in the Firestore.
  ///
  /// Usage is as same as the example in [FirebaseRepository.query]
  /// and [FirebaseRepository.queryGroup]
  Future<Iterable<T>> queryGroupSingle({
    required QueryTransformer spec,
    required String collectionPath,
    Source source = Source.serverAndCache,
  }) async {
    return _query2future(
      FirebaseFirestore.instance.collectionGroup(collectionPath),
      spec,
      source,
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
    DocumentReference? parent,
    MapperCallback<T>? mapper,
  }) async {
    final data = mapper?.call(item) ?? toMap(item, setOptions);
    if (item.ref == null) {
      return await add(item: item, parent: parent);
    }
    if (await _checkConnectivity()) {
      await item.ref!.update(data);
    } else {
      item.ref!.update(data);
    }
    return item.ref!;
  }
}
