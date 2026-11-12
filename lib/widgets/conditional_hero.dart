import 'package:flutter/material.dart';

class ConditionalHero extends StatelessWidget {

  final Object? tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  const ConditionalHero({
    super.key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder
  });

  @override
  Widget build(BuildContext context) {
    return tag == null ? child : Hero(
      tag: tag!,
      flightShuttleBuilder: flightShuttleBuilder,
      child: child
    );
  }
}

/// Animates text in hero elements by lerping between two text styles
Widget textHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final fromText = (fromHeroContext.widget as Hero).child as Text;
  final toText = (toHeroContext.widget as Hero).child as Text;

  final fromStyle = DefaultTextStyle.of(fromHeroContext).style.merge(fromText.style).copyWith(inherit: false);
  final toStyle = DefaultTextStyle.of(toHeroContext).style.merge(toText.style).copyWith(inherit: false);

  final isPush = direction == HeroFlightDirection.push;
  final startStyle = isPush ? fromStyle : toStyle;
  final endStyle = isPush ? toStyle : fromStyle;
  final text = isPush ? toText.data : fromText.data;

  return Material(
    type: MaterialType.transparency,
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text ?? "",
            style: TextStyle.lerp(startStyle, endStyle, animation.value),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        );
      },
    ),
  );
}
