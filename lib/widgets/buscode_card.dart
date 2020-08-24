import 'package:flutter/material.dart';
import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:camera_tutorial/screens/result_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class BuscodeCard extends StatelessWidget {
  final BuscodeView buscode;

  BuscodeCard({Key key, @required this.buscode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.1),
            blurRadius: 10.0,
            spreadRadius: 0,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          pushNewScreen(
            context,
            screen: ResultScreen(
              buscodeView: buscode,
            ),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Card(
          elevation: 0,
//        margin: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date and time',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(
                              0xff656565,
                            ),
                          ),
                        ),
                        Text(
                          '${buscode.day}/${buscode.month} - ${buscode.hour}h${buscode.minute}',
                          style: TextStyle(
                              height: 1.3,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Equipment ID',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff656565))),
                        Text(
                          buscode.equipmentId,
                          style: TextStyle(
                              height: 1.3,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IDTag',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xff656565))),
                    Text(
                      buscode.idTag,
                      style: TextStyle(
                          height: 1.4,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
