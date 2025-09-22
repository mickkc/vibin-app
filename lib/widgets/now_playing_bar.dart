import 'package:flutter/material.dart';

class NowPlayingBar extends StatelessWidget {

  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
              padding: EdgeInsets.zero
            ),
            child: Slider(
              onChanged: (value) {},
              value: 0,
              min: 0,
              max: 10 * 1000 * 60
            ),
          ),
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Track Title", style: Theme.of(context).textTheme.bodyLarge),
                        Text("Artist Name", style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ],
                ),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.skip_next)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}