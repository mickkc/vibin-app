import 'package:flutter/cupertino.dart';

class ConditionalHero extends StatelessWidget {

  final Object? tag;
  final Widget child;

  const ConditionalHero({ super.key, required this.tag, required this.child });

  @override
  Widget build(BuildContext context) {
    return tag == null ? child : Hero(tag: tag!, child: child);
  }
}