import 'package:post_it/models/buscode_view.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:post_it/widgets/result_card.dart';
import 'package:post_it/widgets/delete_warning.dart';
import 'package:post_it/functions/image_processing.dart';

class ResultScreen extends StatelessWidget {
  final BuscodeView buscodeView;
  ResultScreen({Key key, @required this.buscodeView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 20),
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
                    buscodeInformation: buscodeView.day + '/' + buscodeView.month),
                ItemResultCard(
                    title: 'Time',
                    buscodeInformation: buscodeView.hour + 'h' + buscodeView.minute),
                ItemResultCard(
                    title: 'Equipment ID',
                    buscodeInformation: buscodeView.equipmentId),
                ItemResultCard(
                    title: 'Issuer code',
                    buscodeInformation: buscodeView.issuerCode),
                ItemResultCard(
                    title: 'Format ID', buscodeInformation: buscodeView.formatId),
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
              child: Text('$path/$fileName', textAlign: TextAlign.right),
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
