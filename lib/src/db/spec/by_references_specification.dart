import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';
import 'package:rxdart/rxdart.dart';

@Deprecated("Use `ReferencesHandler` instead. Will be removed in v1.0.0")
class ByReferencesSpecification implements SpecificationI {
  final List<DocumentReference> _documentReferences;

  ByReferencesSpecification(this._documentReferences);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    if (_documentReferences.length == 0) {
      return Stream.empty();
    }
    final snapshots = <String, DocumentSnapshot>{};
    final streams =
        _documentReferences.map<Stream<List<DocumentSnapshot>>>((ref) {
      return ref.snapshots().transform(StreamTransformer<DocumentSnapshot,
          List<DocumentSnapshot>>.fromHandlers(handleData: (data, sink) {
        snapshots[data.documentID] = data;
        final values = snapshots.values;
        sink.add(values.toList());
      }));
    }).toList();

    return MergeStream(streams).asBroadcastStream();
  }
}
