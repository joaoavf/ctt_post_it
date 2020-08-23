import 'package:flutter/material.dart';
import 'dart:io';

import 'package:camera_tutorial/functions/image_processing.dart';

void deleteBuscode() async {
  try {
    final file = File('$path/$fileName.jpg');
    await file.delete();
    imageCache.clear();
  } catch (e) {
    print(e);
  }
}

class DeleteWarning extends StatelessWidget {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete this item?'),
      content: Text('This is permanent and cannot be undone.'),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.close, color: Colors.black54),
                  Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.delete, color: Theme.of(context).primaryColor),
                  Text(
                    'Delete',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )
                ],
              ),
              onPressed: () {
                deleteBuscode();
                Navigator.of(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
