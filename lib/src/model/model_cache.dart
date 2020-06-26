import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/fcode_bloc.dart';

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
  static const _instances = <String, ModelCache>{};

  /// {@macro model_cache}
  factory ModelCache() {
    final name = T.toString();
    if (_instances[name] == null) {
      _instances[name] = ModelCache._(name);
    }
    return _instances[name];
  }

  ModelCache._(String name)
      : _timeout = ModelCacheSettings._timeouts[name],
        _addon = ModelCacheSettings._addons[name] {
    if (_timeout == null || _addon == null) {
      throw Exception("Cannot find settings for the DBModelI type $name. "
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

  final int _timeout;
  final RepositoryAddon<T> _addon;
}

/// Used to set settings that can be used in [ModelCache].
///
/// [ModelCache] uses the information provided with the [setSettings]
/// method to get information from the caches. For examples on how to use
/// this method, read its documentation.
///
/// See Also:
///
/// [ModelCache] - Use the settings set by this for each [DBModelI]
/// [RepositoryAddon] - Used to fetch data from [DocumentReference]
/// [FirebaseRepository] - Used to fetch data from Firestore and wrap
/// them in models.
class ModelCacheSettings {
  static const _addons = <String, RepositoryAddon>{};
  static const _timeouts = <String, int>{};

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
  /// ModelCacheSettings.setSettings(...);
  ///
  /// // Correct way of using this function.
  ///
  /// ModelCacheSettings.setSettings<User>(...);
  /// ```
  ///
  static void setSettings<T extends DBModelI>({
    RepositoryAddon<T> addon,
    int timeout,
  }) {
    final name = T.toString();
    _addons[name] = addon;
    _timeouts[name] = timeout;
  }
}
