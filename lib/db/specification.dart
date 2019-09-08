import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SpecificationI {
  Stream<QuerySnapshot> specify(CollectionReference collection);
}
