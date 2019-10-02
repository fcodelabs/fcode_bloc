import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/reference_handler.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/material.dart';

class ReferencesHandler<T extends DBModel> {
  final handlers = <ReferenceHandler>[];

  ReferencesHandler({@required FirebaseRepository<T> repository, List<DocumentReference> references}) {
    for (final ref in references) {
      handlers.add(ReferenceHandler(
        repository: repository,
        reference: ref,
      ));
    }
  }

  Future<List<T>> request() async {
    final items = <T>[];
    for (final handle in handlers) {
      items.add(await handle.request());
    }
    return items;
  }
}
