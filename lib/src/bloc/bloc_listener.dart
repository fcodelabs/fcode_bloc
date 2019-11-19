// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fcode_bloc/src/bloc/bloc.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as _fb;

class BlocListener<B extends BLoC<dynamic, S>, S extends UIModel>
    extends _fb.BlocListener<B, S> {
  const BlocListener({
    Key key,
    @required _fb.BlocWidgetListener<S> listener,
    B bloc,
    _fb.BlocListenerCondition<S> condition,
    Widget child,
  }) : super(
          key: key,
          listener: listener,
          bloc: bloc,
          condition: condition,
          child: child,
        );
}
