import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SpecificationI {
  Stream<DocumentSnapshot> specify(CollectionReference collection);
}
