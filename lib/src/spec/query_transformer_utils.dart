// This file provides [QueryTransformation] wrappers to common
// Firebase querying methods.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'query_transformer.dart';

/// {@template limitOp}
/// Limit the queried data to a given length.
///
/// Same as [Query.limit]. Look at firestore documentation for more.
/// {@endtemplate}
class Limit implements QueryTransformer {
  final int _length;

  /// {@macro limitOp}
  Limit(this._length);

  @override
  Query transform(Query q) {
    return q.limit(_length);
  }
}

/// {@template orderOp}
/// Order the queried data in ascending or descending order. Provide the
/// `field` that the data is needed to ordered with.
/// [descending] will determine the order.
///
/// Same as [Query.orderBy]. Look at firestore documentation for more.
/// {@endtemplate}
class OrderBy implements QueryTransformer {
  final String _field;

  /// If [descending] is `true`, the documents will be ordered in
  /// descending order and in ascending order otherwise.
  final bool descending;

  /// {@macro orderOp}
  OrderBy(this._field, {this.descending = false});

  @override
  Query transform(Query q) {
    return q.orderBy(_field, descending: descending);
  }
}

/// {@template whereOp}
/// Apply where operation to the queried data. Provide the `field`
/// that the data is needed to be filtered. Other fields will specify how.
///
/// Same as [Query.where]. Look at firestore documentation for more.
/// {@endtemplate}
class ComplexWhere implements QueryTransformer {
  final Object _field;

  /// If provided, this will find documents where the provided field is equal
  /// to [isEqualTo].
  final Object? isEqualTo;

  /// If provided, this will find documents where the provided field is less
  /// than [isLessThan].
  final Object? isLessThan;

  /// If provided, this will find documents where the provided field is less
  /// than or equal to [isLessThanOrEqualTo].
  final Object? isLessThanOrEqualTo;

  /// If provided, this will find documents where the provided field is greater
  /// than [isGreaterThan].
  final Object? isGreaterThan;

  /// If provided, this will find documents where the provided field is greater
  /// than or equal to [isGreaterThanOrEqualTo].
  final Object? isGreaterThanOrEqualTo;

  /// If provided, this will find documents where the value [arrayContains]
  /// is in the `field` which contains an array.
  final Object? arrayContains;

  /// If provided, this will find documents where the given array by `field`
  /// which contains any of the values in [arrayContainsAny].
  final List<Object>? arrayContainsAny;

  /// -
  final List<Object>? whereIn;

  /// -
  final List<Object>? whereNotIn;

  /// If provided, this will find documents where the provided field is null
  final bool? isNull;

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
    this.whereNotIn,
    this.isNull,
  });

  @override
  Query transform(Query q) {
    return q.where(
      _field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      whereNotIn: whereNotIn,
      isNull: isNull,
    );
  }
}
