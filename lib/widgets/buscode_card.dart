import 'package:flutter/material.dart';
import 'package:camera_tutorial/screens/result_screen.dart';

class BuscodeCard extends StatefulWidget {
  @override
  _BuscodeCardState createState() => _BuscodeCardState();
}

class _BuscodeCardState extends State<BuscodeCard> {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => (ResultScreen())),
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
                          '16/06 - 15h05',
                          style: TextStyle(
                              height: 1.3,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
//                SizedBox(
//                  width: 66,
//                ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Equipment ID',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff656565))),
                        Text(
                          '153',
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
                      'F49DTPV1295330002830212F',
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
