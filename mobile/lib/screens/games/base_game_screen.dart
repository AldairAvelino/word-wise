import 'package:flutter/material.dart';

abstract class BaseGameScreen extends StatefulWidget {
  final String title;
  final Color color;

  const BaseGameScreen({
    super.key,
    required this.title,
    required this.color,
  });
}

abstract class BaseGameScreenState<T extends BaseGameScreen> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: buildGameHeader(),
            ),
            Expanded(
              child: buildGameContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameHeader();
  Widget buildGameContent();
} 