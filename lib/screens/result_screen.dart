import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';
import 'package:camera_tutorial/ui_components/bottom_navigation_bar.dart';
import 'package:camera_tutorial/ui_components/result_card.dart';
import 'package:image/image.dart' as imglib;

class ResultScreen extends StatelessWidget {
  final Buscode buscode;
  ResultScreen({Key key, @required this.buscode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 8),
              child: Image.memory(imglib.encodeJpg(buscode.buscodeImage)),
            ),
            GridView.count(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              childAspectRatio: 5 / 3,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                ItemResultCard(
                    title: 'Date',
                    buscodeInformation:
                        buscode.decoded.day + '/' + buscode.decoded.month),
                ItemResultCard(
                    title: 'Time',
                    buscodeInformation:
                        buscode.decoded.hour + 'h' + buscode.decoded.minute),
                ItemResultCard(
                    title: 'Equipment ID',
                    buscodeInformation: buscode.decoded.equipmentId),
                ItemResultCard(
                    title: 'Issuer code',
                    buscodeInformation: buscode.decoded.issuerCode),
                ItemResultCard(
                    title: 'Format ID',
                    buscodeInformation: buscode.decoded.formatId),
                ItemResultCard(
                    title: 'Item priority',
                    buscodeInformation: buscode.decoded.itemPriority),
                ItemResultCard(
                    title: 'Serial number',
                    buscodeInformation: buscode.decoded.serialNumber),
                ItemResultCard(
                    title: 'Tracking indicator',
                    buscodeInformation: buscode.decoded.trackingIndicator),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
