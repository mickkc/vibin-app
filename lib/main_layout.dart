import 'package:flutter/material.dart';
import 'package:vibin_app/dialogs/lyrics_dialog.dart';
import 'package:vibin_app/widgets/nowplaying/now_playing_queue.dart';

enum SidebarType {
  none,
  queue,
  lyrics
}

class MainLayoutView extends StatefulWidget {
  final Widget mainContent;

  const MainLayoutView({
    super.key,
    required this.mainContent
  });

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

ValueNotifier<SidebarType> sidebarNotifier = ValueNotifier(SidebarType.none);

class _MainLayoutViewState extends State<MainLayoutView> {

  double get _width => MediaQuery.of(context).size.width;
  late double _sideBarWidth = 300;

  var _isSidebarTooSmall = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(
          child: widget.mainContent,
        ),

        if (_width > 900)
          ValueListenableBuilder(
            valueListenable: sidebarNotifier,
            builder: (context, value, child) {
              if (value == SidebarType.none || _width <= 900) return SizedBox.shrink();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sideBarWidth -= details.delta.dx;

                        if (_sideBarWidth < 300) {
                          _sideBarWidth = 300;
                          _isSidebarTooSmall = true;
                          return;
                        }
                        else {
                          _isSidebarTooSmall = false;
                        }

                        _sideBarWidth = _sideBarWidth.clamp(300, _width / 3);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_isSidebarTooSmall) {
                        sidebarNotifier.value = SidebarType.none;
                        _isSidebarTooSmall = false;
                      }
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: Container(
                        width: 8,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  if (!_isSidebarTooSmall)
                    SizedBox(
                      width: _sideBarWidth,
                      child: switch (value) {
                        SidebarType.queue => NowPlayingQueue(),
                        SidebarType.lyrics => LyricsDialog(),
                        SidebarType.none => SizedBox.shrink()
                      },
                    ),
                ],
              );
            }
          )
      ]
    );
  }
}