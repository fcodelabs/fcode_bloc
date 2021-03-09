import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface that will provide basic functionality for a [DBModel] that
/// is used to store a document in Firestore.
///
/// When using this with built_value package make sure to implement only
/// [id] in the abstract class
///
/// ```dart
/// abstract class HealthForm
///     implements DBModelI, Built<HealthForm, HealthFormBuilder> {
///
///   // other attributes
///   String get id => ref.documentID;
///
///   HealthForm._();
///
///   factory HealthForm([void Function(HealthFormBuilder) updates])
///     = _$HealthForm;
/// }
/// ```
abstract class DBModelI {
  /// Store the [DocumentReference] of the document
  ///
  /// For more see [DBModel.ref]
  DocumentReference? get ref;

  /// Generate a [id] for the interface [DBModelI]
  ///
  /// For more see [DBModel.id]
  String? get id;
}
