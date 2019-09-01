import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SpecificationI {
  void specify(CollectionReference collection);
}
