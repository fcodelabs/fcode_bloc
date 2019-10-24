// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fcode_bloc/src/bloc/bloc.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as _fb;

class BlocBuilder<B extends BLoC<dynamic, S>, S extends UIModel> extends _fb.BlocBuilder<B, S> {
  const BlocBuilder({
    Key key,
    @required _fb.BlocWidgetBuilder<S> builder,
    B bloc,
    _fb.BlocBuilderCondition<S> condition,
  }) : super(
          key: key,
          builder: builder,
          bloc: bloc,
          condition: condition,
        );
}
