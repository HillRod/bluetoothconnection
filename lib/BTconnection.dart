import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BTconnection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _BTconnectionState();
  }
}

class _BTconnectionState extends State<BTconnection> {
  //--------------------Bluetooth setup------------------------
  //------------------------begin------------------------------
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  List<TextEditingController> listaCtrl = List<TextEditingController>();

  // This member variable will be used for tracking
  // the Bluetooth device connection state
  int _deviceState;

  int cont = 0;

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());
    listaCtrl.add(new TextEditingController());

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _deviceState = 0; // neutral

    // If the Bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // For retrieving the paired devices list
        getPairedDevices();
      });
    });
  }

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
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
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
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

    if (cont < 8) {
      for (var i = 0; i < messages.length; i++) {
        messages.elementAt(i).text =
            messages.elementAt(i).text.replaceAll('\n', '');
        listaCtrl.elementAt(i).text = messages.elementAt(i).text;
      }
    } else if (cont == 8) {
      connection.close();
    }
    cont++;
  }

  //-------------------------end-------------------------------
  String placeholder = 'Medida';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: _isButtonUnavailable &&
              _bluetoothState == BluetoothState.STATE_ON,
          child: LinearProgressIndicator(
            //loading bar colors
            backgroundColor: Colors.blue,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Habilitar Bluetooth',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              Switch(
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  future() async {
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }

                    await getPairedDevices();
                    _isButtonUnavailable = false;

                    if (_connected) {
                      _disconnect();
                    }
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              FlatButton.icon(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
                label: Text(
                  "Refresh",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                splashColor: Colors.blue,
                onPressed: () async {
                  await getPairedDevices().then((_) {
                    show('Device list refreshed');
                  });
                },
              ),
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Dispositivos Emparejados",
                    style: TextStyle(fontSize: 24, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Dispositivo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty ? _device : null,
                      ),
                      RaisedButton(
                        onPressed: _isButtonUnavailable
                            ? null
                            : _connected ? _disconnect : _connect,
                        child: Text(_connected ? 'Desconectar' : 'Conectar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.blue,
            ),
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
                    labelText: placeholder,
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
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
