// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PressableCard extends StatefulWidget {
  const PressableCard({
    this.onPressed,
    this.color,
    this.flattenAnimation,
    this.child,
  });

  final VoidCallback onPressed;
  final Color color;
  final Animation<double> flattenAnimation;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  bool pressed = false;
  AnimationController controller;
  Animation<double> elevationAnimation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 40),
    );
    elevationAnimation =
        controller.drive(CurveTween(curve: Curves.easeInOutCubic));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get flatten => 1 - widget.flattenAnimation.value;

  @override
  Widget build(context) {
    return Listener(
      onPointerDown: (details) {
        if (widget.onPressed != null) {
          controller.forward();
        }
      },
      onPointerUp: (details) {
        controller.reverse();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onPressed != null) {
            widget.onPressed();
          }
        },
        // This widget both internally drives an animation when pressed and
        // responds to an external animation to flatten the card when in a
        // hero animation. You likely want to modularize them more in your own
        // app.
        child: AnimatedBuilder(
          animation:
              Listenable.merge([elevationAnimation, widget.flattenAnimation]),
          child: widget.child,
          builder: (context, child) {
            return Transform.scale(
              // This is just a sample. You likely want to keep the math cleaner
              // in your own app.
              scale: 1 - elevationAnimation.value * 0.03,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16) *
                    flatten,
                child: PhysicalModel(
                  elevation:
                      ((1 - elevationAnimation.value) * 10 + 10) * flatten,
                  borderRadius: BorderRadius.circular(12 * flatten),
                  clipBehavior: Clip.antiAlias,
                  color: widget.color,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeroAnimatingSongCard extends StatelessWidget {
  HeroAnimatingSongCard(
      {this.imageUri,
      this.song,
      this.color,
      this.heroAnimation,
      this.onPressed});

  final String imageUri;
  final String song;
  final Color color;
  final Animation<double> heroAnimation;
  final VoidCallback onPressed;

  double get playButtonSize => 50 + 50 * heroAnimation.value;

  @override
  Widget build(context) {
    // This is an inefficient usage of AnimatedBuilder since it's rebuilding
    // the entire subtree instead of passing in a non-changing child and
    // building a transition widget in between.
    //
    // Left simple in this demo because this card doesn't have any real inner
    // content so this just rebuilds everything while animating.
    return AnimatedBuilder(
      animation: heroAnimation,
      builder: (context, child) {
        return PressableCard(
          onPressed: heroAnimation.value == 0 ? onPressed : null,
          color: color,
          flattenAnimation: heroAnimation,
          child: SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 170,
                      color: Colors.black26,
                      child: imageUri == null
                          ? null
                          : Image(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.center,
                              image: NetworkImage(imageUri),
                            ),
                    )),
                // The song title banner slides off in the hero animation.
                Positioned(
                  bottom: -80 * heroAnimation.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.white10,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      song,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // The play button grows in the hero animation.
                // Padding(
                //   padding:
                //       EdgeInsets.only(bottom: 45) * (1 - heroAnimation.value),
                //   child: Container(
                //     height: playButtonSize,
                //     width: playButtonSize,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.black12,
                //     ),
                //     alignment: Alignment.center,
                //     child: Icon(Icons.play_arrow,
                //         size: playButtonSize, color: Colors.black38),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SongPlaceholderTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            Container(
              color: Theme.of(context).textTheme.bodyText2.color,
              width: 130,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 60),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 20, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 40, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 80, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 50, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showChoices(BuildContext context, List<String> choices) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      showDialog<void>(
        context: context,
        builder: (context) {
          var selectedRadio = 1;
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 12),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(choices.length, (index) {
                    return RadioListTile(
                      title: Text(choices[index]),
                      value: index,
                      groupValue: selectedRadio,
                      // ignore: avoid_types_on_closure_parameters
                      onChanged: (int value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    case TargetPlatform.iOS:
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: CupertinoPicker(
              backgroundColor: Theme.of(context).canvasColor,
              useMagnifier: true,
              magnification: 1.1,
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: 1),
              children: List<Widget>.generate(choices.length, (index) {
                return Center(
                  child: Text(
                    choices[index],
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                );
              }),
              onSelectedItemChanged: (value) {},
            ),
          );
        },
      );
      return;
    default:
      assert(false, 'Unexpected platform $defaultTargetPlatform');
  }
}
