import 'package:flutter/material.dart';

class DummyEntityCard extends StatelessWidget {
  final String? title;
  final double coverSize;

  const DummyEntityCard({
    super.key,
    this.title,
    this.coverSize = 128,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: coverSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: SizedBox(
                  width: coverSize,
                  height: coverSize,
                  child: Center(
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  )
                ),
              ),
              const Expanded(child: SizedBox())
            ],
          ),
        ),
      ),
    );
  }
}
