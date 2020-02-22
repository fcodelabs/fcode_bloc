import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../fcode_bloc.dart';

/// {@template model}
/// A [FirebaseRepository] will return models of this type once data is
/// retrieved from the DB.
///
/// Write a subclass with the attributes that you need to be stored in
/// this [DBModel] from the Firestore.
/// Implement [FirebaseRepository.fromSnapshot] and [FirebaseRepository.toMap]
/// to convert a [DocumentSnapshot] to a [DBModel] of the required type and
/// to convert a [DBModel] to a [Map] that can be stored in Firestore.
///
/// A simple implementation can be seen in the documentation of [DBModel.clone]
/// {@endtemplate}
@immutable
abstract class DBModel extends Equatable {

  /// Store the [DocumentReference] of this [DBModel] which will represent
  /// a document in Firestore. All [DBModel] which is return from
  /// [FirebaseRepository.fromSnapshot] should have a [ref].
  ///
  /// Otherwise can be null.
  final DocumentReference ref;

  /// {@macro model}
  DBModel({this.ref});

  @override
  bool operator ==(Object other) {
    if (other is DBModel) {
      return other.ref?.path == ref?.path;
    }
    return false;
  }

  @override
  int get hashCode {
    return ref?.hashCode ?? 0;
  }

  @override
  String toString() {
    return "Reference: ${ref?.path}";
  }

  /// Should return a copy of [DBModel].
  /// This method is not use by any of the classes in this library.
  /// So, implement this method if you see the need.
  ///
  /// Eg:
  /// ```dart
  /// class Person extends DBModel {
  ///   final String name;
  ///   final int age;
  ///   final double height;
  ///
  ///   Person({this.name, this.height, this.age});
  ///
  ///   @override
  ///   Person clone({String name, int age, double height}) {
  ///     return Person(
  ///       name: name ?? this.name,
  ///       age: age ?? this.age,
  ///       height: height ?? this.height,
  ///     );
  ///   }
  /// }
  /// ```
  DBModel clone() {
    return null;
  }

  /// Generate a [id] for the [DBModel].
  /// Internally this will generate an ID for newly created documents.
  ///
  /// Can be null. If it is null, random id will be given to the
  /// created document.
  String get id => ref?.documentID;
}
