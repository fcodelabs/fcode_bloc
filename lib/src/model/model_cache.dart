import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../repo/repository_addon.dart';
import 'db_model_i.dart';

/// {@template model_cache}
/// Create a memory cache for Models. For this module to work correctly
/// Firebase cache has to be turned on. (It is automatically on unless
/// you change Firebase configuration to turn it off)
///
/// This will store the fetches done through here in memory.
///
/// If it is not in memory, this loads data from firebase cache. And
/// will store the data in memory for later fetches.
///
/// If it is not available in firebase cache also it will get the
/// data from online Firestore and save in memory for later user.
///
/// In any of the above cases, if the data fetched is older than
/// [_timeout] minutes, it will send a request to get the data from online
/// Firestore from the background and store it in the memory. So the data
/// will be available in the next time you fetch.
///
/// Before using [ModelCache] with a specific [DBModelI] implementation,
/// configurations for that specific [DBModelI] has to be set through
/// [ModelCacheSettings]. Otherwise this will throw an [Exception].
///
/// See Also:
///
/// [ModelCacheSettings] - Store the setting information for each [DBModelI]
/// [RepositoryAddon] - Used to fetch data from [DocumentReference]
/// [FirebaseRepository] - Used to fetch data from Firestore and wrap
/// them in models.
/// {@endtemplate}
class ModelCache<T extends DBModelI> {
  static final _instances = <String, ModelCache>{};
  static final _addons = <String, RepositoryAddon>{};
  static final _timeouts = <String, int>{};

  /// Store the settings provided for a specific type of [DBModelI].
  ///
  /// If settings was provided for the same [DBModelI] more that once,
  /// this will not replace the settings of the already created [ModelCache]
  /// instances. The correct settings value has to set before creating
  /// a instance of [ModelCache] for the given type [T].
  ///
  /// But before instantiating the [ModelCache] for the type [T], this
  /// function can be called multiple times. [ModelCache] will use the last
  /// values that this function was called with.
  ///
  /// Eg: Let's say you need to set settings for a model called User
  /// which extends [DBModelI].
  ///
  /// ```dart
  ///
  /// // Wrong way of using this function.
  ///
  /// ModelCache.setSettings(...);
  ///
  /// // Correct way of using this function.
  ///
  /// ModelCache.setSettings<User>(...);
  /// ```
  ///
  /// Parameter Description
  ///
  /// [addon] - An instance of [RepositoryAddon] for this [T]
  /// [timeout] - Timeout period in minutes which [ModelCache] will re-fetch
  /// data from Firestore server (Default 60).
  static void setSettings<T extends DBModelI>({
    @required RepositoryAddon<T> addon,
    int timeout = 60,
  }) {
    final name = T.toString();
    _addons[name] = addon;
    _timeouts[name] = timeout;
  }

  /// {@macro model_cache}
  factory ModelCache() {
    final name = T.toString();
    if (_instances[name] == null) {
      _instances[name] = ModelCache<T>._();
    }
    return _instances[name];
  }

  ModelCache._()
      : _timeout = _timeouts[T.toString()],
        _addon = _addons[T.toString()] {
    if (_timeout == null || _addon == null) {
      throw Exception("Cannot find settings for the DBModelI type $T. "
          "You can set settings for this type using ModelCacheSettings. "
          "Make sure to use the correct type when calling the setSettings "
          "function of that class.\n"
          "Eg: ModelCacheSettings.setSettings(...) is not the correct way "
          "of adding settings.\n"
          "To add settings to type User (which extends DBModelI) you can use\n"
          "Eg: ModelCacheSettings.setSettings<User>(...) \n\n"
          "If the issue still persists, use our github to create a issue.\n"
          "https://github.com/fcodelabs/fcode_bloc/issues");
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  final _items = <String, T>{};
  final _updated = <String, DateTime>{};
  final int _timeout;
  final RepositoryAddon<T> _addon;

  /// Get the cached data directly from memory
  T fromMem(DocumentReference ref) {
    assert(ref != null);
    fetch(ref);
    return _items[ref.path];
  }

  void _fetch(DocumentReference ref, [Completer completer]) {
    final diff = _updated[ref.path]?.difference(DateTime.now());
    if ((diff?.inMinutes?.abs() ?? _timeout) >= _timeout) {
      _addon.fetch(ref: ref, source: Source.server).then((item) {
        _items[ref.path] = item;
        _updated[ref.path] = DateTime.now();
        completer?.complete();
      });
    } else {
      completer?.complete();
    }
  }

  /// Fetch data from
  /// 1. Memory
  /// 2. Firebase cache if not available in memory
  /// 3. Firestore server if not available in cache
  ///
  /// in the given order for the given [ref].
  Future<T> fetch(DocumentReference ref) async {
    final completer = Completer();
    _fetch(ref, completer);

    final memItem = _items[ref.path];
    if (memItem != null) {
      return memItem;
    }

    final item = await _addon.fetch(
      ref: ref,
      source: Source.cache,
      exception: false,
    );
    _items[ref.path] = item;

    if (item != null) {
      return item;
    }
    await completer.future;
    return _items[ref.path];
  }

  /// Same as [fetch] but for multiple list of [DocumentReference]s, [refs]
  Future<List<T>> multiFetch(Iterable<DocumentReference> refs) async {
    final usersF = refs.map(fetch);
    return await Future.wait(usersF);
  }

  /// Clear memory cache
  void clearMem() {
    _items.clear();
    _updated.clear();
  }
}
