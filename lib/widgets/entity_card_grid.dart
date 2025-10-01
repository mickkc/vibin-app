import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'entity_card.dart';

class EntityCardGrid extends StatelessWidget {
  final List<dynamic> items;
  final String type;
  final double maxWidthPerColumn;

  const EntityCardGrid({
    super.key,
    required this.items,
    this.maxWidthPerColumn = 150,
    this.type = "TRACK"
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = max((width / 150).floor(), 2);
    final widthPerCol = (width - ((cols - 1) * 8)) / cols;
    final height = (widthPerCol - 16) + 85;

    return SizedBox(
      height: (items.length / cols).ceil() * height + ((items.length / cols).ceil() - 1) * 8,
      child: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: height,
          ),
          itemCount: items.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return EntityCard(entity: items[index], coverSize: widthPerCol - 16, type: type);
          }
        ),
      ),
    );
  }
}