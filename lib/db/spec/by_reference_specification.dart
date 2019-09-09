import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/bloc/default_stream_transformer.dart';
import 'package:fcode_bloc/db/specification.dart';

class ByReferenceSpecification implements SpecificationI {
  final DocumentReference _documentReference;

  ByReferenceSpecification(this._documentReference);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    return _documentReference.snapshots().transform(
        DefaultStreamTransformer.transformer<DocumentSnapshot, List<DocumentSnapshot>>(handleData: (data, sink) {
      sink.add([data]);
    }));
  }
}
