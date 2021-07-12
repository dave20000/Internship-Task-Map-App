import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_map/services/service_locator.dart';

class BaseWidget<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Function(T)? onModelReady;
  final Function(T)? onDispose;

  BaseWidget({required this.builder, this.onModelReady, this.onDispose});

  @override
  _BaseWidgetState createState() => _BaseWidgetState();
}

class _BaseWidgetState<T extends ChangeNotifier> extends State<BaseWidget>
    with AutomaticKeepAliveClientMixin {
  final T viewModel = ServiceLocator.resolve<T>();
  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady!(viewModel);
    }
    super.initState();
  }

  void dispose() {
    if (widget.onDispose != null) {
      widget.onDispose!(viewModel);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<T>(
      create: (context) => viewModel,
      child: Consumer<T>(builder: widget.builder),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
