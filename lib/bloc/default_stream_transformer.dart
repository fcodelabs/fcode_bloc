import 'dart:async';

import 'package:flutter/material.dart';

abstract class DefaultStreamTransformer {
  DefaultStreamTransformer._();

  static StreamTransformer<From, To> transformer<From, To>({
    @required void handleData(From data, EventSink<To> sink),
    void handleError(Object error, StackTrace stackTrace, EventSink<To> sink),
    void handleDone(EventSink<To> sink),
}) {
    handleError = handleError ?? (error, stackTrace, sink) => sink.addError(error, stackTrace);
    handleDone = handleDone ?? (sink) => sink.close();
    return StreamTransformer<From, To>.fromHandlers(
      handleData: handleData,
      handleError: handleError,
      handleDone: handleDone,
    );
  }
}
