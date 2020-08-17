import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';
import 'package:camera_tutorial/widgets/bottom_navigation_bar.dart';
import 'package:camera_tutorial/widgets/result_card.dart';
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
              child: Image.memory(imglib.encodeJpg(buscode.image)),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                buscode.idTag,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
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
                    buscodeInformation: buscode.day + '/' + buscode.month),
                ItemResultCard(
                    title: 'Time',
                    buscodeInformation: buscode.hour + 'h' + buscode.minute),
                ItemResultCard(
                    title: 'Equipment ID',
                    buscodeInformation: buscode.equipmentId),
                ItemResultCard(
                    title: 'Issuer code',
                    buscodeInformation: buscode.issuerCode),
                ItemResultCard(
                    title: 'Format ID', buscodeInformation: buscode.formatId),
                ItemResultCard(
                    title: 'Item priority',
                    buscodeInformation: buscode.itemPriority),
                ItemResultCard(
                    title: 'Serial number',
                    buscodeInformation: buscode.serialNumber),
                ItemResultCard(
                    title: 'Tracking indicator',
                    buscodeInformation: buscode.trackingIndicator),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
