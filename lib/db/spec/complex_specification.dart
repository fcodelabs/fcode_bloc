import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_mvp/bloc/default_stream_transformer.dart';
import 'package:fcode_mvp/db/specification.dart';

class ComplexSpecification implements SpecificationI {
  List<ComplexOperation> _complexWhere;

  ComplexSpecification(this._complexWhere);

  @override
  Stream<DocumentSnapshot> specify(CollectionReference collection) {
    if (_complexWhere == null) {
      return Stream<DocumentSnapshot>.empty();
    }
    Query query = collection;
    for (final cw in _complexWhere) {
      query = cw.perform(query);
    }
    return query.snapshots().transform(DefaultStreamTransformer.transformer<QuerySnapshot, DocumentSnapshot>(
      handleData: (data, sink) {
        for (final document in data.documents) {
          sink.add(document);
        }
      },
    ));
  }
}

abstract class ComplexOperation {
  Query perform(Query query);
}

class Limit implements ComplexOperation {
  final int _length;

  Limit(this._length);

  @override
  Query perform(Query query) {
    return query.limit(_length);
  }
}

class OrderBy implements ComplexOperation {
  final String _field;
  final bool descending;

  OrderBy(this._field, {this.descending = false});

  @override
  Query perform(Query query) {
    return query.orderBy(_field, descending: descending);
  }
}

class ComplexWhere implements ComplexOperation {
  final String _field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  bool isNull;

  ComplexWhere(
    this._field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
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
      isNull: isNull,
    );
  }
}
