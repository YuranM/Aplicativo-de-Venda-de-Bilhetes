import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class HeartButtomWidget extends StatefulWidget {
  final double size;
  final Color colors;

  const HeartButtomWidget({
    super.key, this.size = 22,
        this.colors = Colors.transparent,
  });

  @override
  State<HeartButtomWidget> createState() => _HeartButtomWidgetState();
}

class _HeartButtomWidgetState extends State<HeartButtomWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.colors,
      ),
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
          onPressed: (){},
          icon: Icon(
            IconlyLight.heart,
            size: widget.size,
          ),
      ),
    );
  }
}
