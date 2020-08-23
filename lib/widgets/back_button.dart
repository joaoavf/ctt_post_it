import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
        padding: EdgeInsets.only(left: 20, top: 10),
      ),
    );
  }
}
