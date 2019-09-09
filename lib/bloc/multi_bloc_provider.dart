import 'package:fcode_bloc/bloc/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiBlocProvider extends MultiProvider {
  MultiBlocProvider({
    Key key,
    @required List<BlocProvider> providers,
    @required Widget child,
  }) : super(
          key: key,
          providers: providers,
          child: child,
        );
}
