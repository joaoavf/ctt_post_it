import 'package:flutter/material.dart';

class DeleteWarning extends StatelessWidget {
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
                print('Item deleted');
              },
            ),
          ],
        ),
      ],
    );
  }
}
