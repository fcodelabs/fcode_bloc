import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_mvp/db/db_model.dart';

abstract class FirebaseRepositoryI<T extends DBModel> {
  T fromSnapshot(DocumentSnapshot snapshot);

  Map<String, dynamic> toMap(T item);
}
