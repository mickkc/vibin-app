import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/router.dart';
import 'package:vibin_app/utils/theme_generator.dart';

class ThemedSvg extends StatefulWidget {
  const ThemedSvg({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  State<ThemedSvg> createState() => _ThemedSvgState();
}

class _ThemedSvgState extends State<ThemedSvg> {
  late Future<String> _svgFuture;

  static RegExp placeholderRegex = RegExp("{{.*}}");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _svgFuture = _loadThemedSvg(context);
  }

  Future<String> _loadThemedSvg(BuildContext context) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final darkest = cs.brightness == Brightness.dark ? cs.surface : cs.onSurface;
    final lightest = cs.brightness == Brightness.dark ? cs.onSurface : cs.surface;
    final primary = cs.brightness == Brightness.dark ? cs.primary : cs.primaryContainer;

    String svg = await rootBundle.loadString(widget.assetPath);

    for (final match in placeholderRegex.allMatches(svg)) {
      String? g = match.group(0);
      if (g == null) {
        continue;
      }
      g = g.substring(2, g.length - 2);
      final parts = g.split(":");
      Color color;

      switch (parts[0]) {
        case "darkest":
          color = darkest;
          break;
        case "lightest":
          color = lightest;
          break;
        case "primary":
          color = primary;
          break;
        case "onbackground":
          color = cs.brightness == Brightness.light ? darkest : lightest;
          break;
        default:
          continue;
      }

      String prefix = "";
      double colorMod = 0;
      if (parts.length > 1) {
        prefix = parts[1][0];
        colorMod = double.parse(parts[1].substring(1));
      }

      if (prefix == "-") {
        color = ThemeGenerator.blendColors(color, darkest, colorMod.abs());
      }
      else if (prefix == "+") {
        color = ThemeGenerator.blendColors(color, lightest, colorMod.abs());
      }
      else if (prefix == "?") {
        color = ThemeGenerator.blendColors(color, cs.brightness == Brightness.light ? lightest : darkest, colorMod.abs());
      }
      else if (prefix == "!") {
        color = ThemeGenerator.blendColors(color, cs.brightness == Brightness.light ? Colors.white : Colors.black, colorMod.abs());
      }

      svg = svg.replaceAll("{{$g}}", color.toHexWithoutAlpha());
    }

    return svg;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: Icon(Icons.broken_image_outlined),
            ),
          );
        }

        return SvgPicture.string(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}