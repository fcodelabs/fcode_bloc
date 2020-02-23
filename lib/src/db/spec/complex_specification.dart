import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../specification.dart';

/// {@template cmpRef}
/// To know how to use [SpecificationI], look at [FirebaseRepository.query].
///
/// Provide a [List] of [ComplexOperation]s to create a [SpecificationI]
/// that can be used to query documents from Firestore using the compound
/// query that can be generated using the [ComplexOperation]s. Query will be
/// created according the order in the provided [List].
/// {@endtemplate}
class ComplexSpecification implements SpecificationI {
  final List<ComplexOperation> _complexWhere;

  /// {@macro cmpRef}
  ComplexSpecification(this._complexWhere) : assert(_complexWhere != null);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    Query query = collection;
    for (final cw in _complexWhere) {
      query = cw.perform(query);
    }
    return query
        .snapshots()
        .map<List<DocumentSnapshot>>((data) => data.documents);
  }

  @override
  Future<List<DocumentSnapshot>> specifySingle(
    CollectionReference collection,
  ) async {
    Query query = collection;
    for (final cw in _complexWhere) {
      query = cw.perform(query);
    }
    return (await query.getDocuments()).documents;
  }
}

/// Provide a interface to generate compound queries inside a
/// [ComplexSpecification].
abstract class ComplexOperation {
  ComplexOperation._();

  /// Perform the operation to the provided [query]. This operation
  /// will query data from the provided Firestore [query].
  ///
  /// For implementations see:
  /// * [Limit] - Limit the data that is queried from the [query] to a
  ///   given number.
  /// * [OrderBy] - Order the documents in the [query].
  /// * [ComplexWhere] - Use `where` to query data.
  Query perform(Query query);
}

/// {@template limitOp}
/// Limit the queried data to a given length.
///
/// Same as [Query.limit]. Look at firestore documentation for more.
/// {@endtemplate}
class Limit implements ComplexOperation {
  final int _length;

  /// {@macro limitOp}
  Limit(this._length);

  @override
  Query perform(Query query) {
    return query.limit(_length);
  }
}

/// {@template orderOp}
/// Order the queried data in ascending or descending order. Provide the
/// `field` that the data is needed to ordered with.
/// [descending] will determine the order.
///
/// Same as [Query.orderBy]. Look at firestore documentation for more.
/// {@endtemplate}
class OrderBy implements ComplexOperation {
  final String _field;

  /// If [descending] is `true`, the documents will be ordered in
  /// descending order and in ascending order otherwise.
  final bool descending;

  /// {@macro orderOp}
  OrderBy(this._field, {this.descending = false});

  @override
  Query perform(Query query) {
    return query.orderBy(_field, descending: descending);
  }
}

/// {@template whereOp}
/// Apply where operation to the queried data. Provide the `field`
/// that the data is needed to be filtered. Other fields will specify how.
///
/// Same as [Query.where]. Look at firestore documentation for more.
/// {@endtemplate}
class ComplexWhere implements ComplexOperation {
  final String _field;

  /// If provided, this will find documents where the provided field is equal
  /// to [isEqualTo].
  final dynamic isEqualTo;

  /// If provided, this will find documents where the provided field is less
  /// than [isLessThan].
  final dynamic isLessThan;

  /// If provided, this will find documents where the provided field is less
  /// than or equal to [isLessThanOrEqualTo].
  final dynamic isLessThanOrEqualTo;

  /// If provided, this will find documents where the provided field is greater
  /// than [isGreaterThan].
  final dynamic isGreaterThan;

  /// If provided, this will find documents where the provided field is greater
  /// than or equal to [isGreaterThanOrEqualTo].
  final dynamic isGreaterThanOrEqualTo;

  /// If provided, this will find documents where the value [arrayContains]
  /// is in the `field` which contains an array.
  final dynamic arrayContains;

  /// If provided, this will find documents where the given array by `field`
  /// which contains any of the values in [arrayContainsAny].
  final List arrayContainsAny;

  /// -
  final List whereIn;

  /// If provided, this will find documents where the provided field is null
  bool isNull;

  /// {@macro whereOp}
  ComplexWhere(
    this._field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    bool isNull = false,
  }) {
    if (isNull) {
      this.isNull = true;
    }
  }

  @override
  Query perform(Query query) {
    return query.where(
      _field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      isNull: isNull,
    );
  }
}
