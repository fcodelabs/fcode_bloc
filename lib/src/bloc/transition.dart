// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart' as _b;
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:flutter/material.dart';

class Transition<Action, State extends UIModel> extends _b.Transition<Action, State> {
  const Transition({
    @required State previousState,
    @required Action action,
    @required State currentState,
  }) : super(
          currentState: previousState,
          event: action,
          nextState: currentState,
        );
}
