import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibin_app/extensions.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _svgFuture = _loadThemedSvg(context);
  }

  Future<String> _loadThemedSvg(BuildContext context) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final darkest = cs.brightness == Brightness.dark ? cs.surface : cs.onSurface;
    final brightest = cs.brightness == Brightness.dark ? cs.onSurface : cs.surface;

    final brightPrimary = cs.brightness == Brightness.dark ? cs.primary : cs.primaryContainer;
    final darkPrimary = cs.brightness == Brightness.dark ? cs.primaryContainer : cs.primary;

    final placeholders = {
      '{{darkest}}': darkest.toHexWithoutAlpha(),
      '{{brightest}}': brightest.toHexWithoutAlpha(),
      '{{brightPrimary}}': brightPrimary.toHexWithoutAlpha(),
      '{{darkPrimary}}': darkPrimary.toHexWithoutAlpha()
    };

    String svg = await rootBundle.loadString(widget.assetPath);

    for (final entry in placeholders.entries) {
      svg = svg.replaceAll(entry.key, entry.value);
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