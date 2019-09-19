import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SpecificationI {
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection);
}
