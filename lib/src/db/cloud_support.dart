import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Create an object that can interact with cloud firestore.
class CloudSupport {

  /// Call the cloud function named [functionName] with the [params].
  /// Return a [Future] of [HttpsCallableResult]
  Future<HttpsCallableResult> call({
    @required String functionName,
    dynamic params,
  }) async {
    assert(functionName != null && functionName.isNotEmpty);
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: functionName,
    );
    return await callable.call(params);
  }
}
