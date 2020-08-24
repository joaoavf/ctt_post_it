import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera_tutorial/widgets/result_card.dart';
import 'package:camera_tutorial/widgets/delete_warning.dart';

class ResultScreen extends StatelessWidget {
  final BuscodeView buscodeView;
  ResultScreen({Key key, @required this.buscodeView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: Text(
          'Buscode Information',
          style: TextStyle(color: Colors.black54),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 30, top: 30),
              child: Image.memory(imglib.encodeJpg(buscodeView.image)),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                buscodeView.idTag,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            GridView.count(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 9 / 4.7,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                ItemResultCard(
                    title: 'Date',
                    buscodeInformation:
                        '${buscodeView.day}/${buscodeView.month}'),
                ItemResultCard(
                    title: 'Time',
                    buscodeInformation:
                        '${buscodeView.hour}h${buscodeView.minute}'),
                ItemResultCard(
                    title: 'Equipment ID',
                    buscodeInformation: buscodeView.equipmentId),
                ItemResultCard(
                    title: 'Issuer code',
                    buscodeInformation: buscodeView.issuerCode),
                ItemResultCard(
                    title: 'Format ID',
                    buscodeInformation: buscodeView.formatId),
                ItemResultCard(
                    title: 'Item priority',
                    buscodeInformation: buscodeView.itemPriority),
                ItemResultCard(
                    title: 'Serial number',
                    buscodeInformation: buscodeView.serialNumber),
                ItemResultCard(
                    title: 'Tracking indicator',
                    buscodeInformation: buscodeView.trackingIndicator),
              ],
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(buscodeView.path, textAlign: TextAlign.right),
            ),
            Container(
              padding: EdgeInsets.only(right: 8),
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return DeleteWarning();
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
