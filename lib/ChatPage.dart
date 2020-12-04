import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';
  String placeholder = 'Medida';

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  var txt = TextEditingController();
  List<TextEditingController> listaCtrl = List<TextEditingController>();

  int cont = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: (isConnecting
                ? Text('Conectando a ' + widget.server.name + '...')
                : isConnected
                    ? Text('Conectado a ' + widget.server.name)
                    : Text('Chat log with ' + widget.server.name))),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de abdominal',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText:
                                  placeholder, 
                            ),
                            controller: listaCtrl.elementAt(0),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de bíceps',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(1),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de cresta ilíaca',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(2),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de muslo anterior',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(3),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de pierna medial',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(4),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de subescapular',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(5),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de supraespinal',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(6),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            'Pliegue de tríceps',
                            style: new TextStyle(fontSize: 36),
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: placeholder,
                            ),
                            controller: listaCtrl.elementAt(7),
                          )),
                          Expanded(child: Text('    cm'))
                        ],
                      )
                    ],
                  )
                ])
          ],
        ));
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        print(backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index));
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    
    if(cont<8){
      for (var i = 0; i < messages.length; i++) {
      messages.elementAt(i).text = messages.elementAt(i).text.replaceAll('\n', '');
      listaCtrl.elementAt(i).text = messages.elementAt(i).text;
    }
    }else if(cont == 8){
      connection.close();
      Navigator.pop(context);
    }
    cont++;
  }
}
