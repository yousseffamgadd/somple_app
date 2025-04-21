import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Layout Demo',
      home: const LoginPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Spreads items
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Choose Brand Name'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://app.sstm-eg.com/dashboards/97e05f20-1c54-11f0-8fdb-1bfadc9443ff'; // Replace with your actual URL
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cooltech', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://app.sstm-eg.com/dashboards/ba8bd5e0-42f2-11ef-bbc1-7bd09edbbc7e'; // Replace with your actual URL
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Airzen', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  minimumSize: const Size(224, 88),
                ),
                child: const Text(
                  'View Stats',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Image.asset(
                'assets/sstm.jpg',
                width: double.infinity,
                height: 287,
                fit: BoxFit.contain,
              ),
              ElevatedButton(
                onPressed: () {
                  // Scan and Edit
                  // Navigate to the ScanAndEditPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanEditPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  minimumSize: const Size(224, 88),
                ),
                child: const Text(
                  'Scan and Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ScanEditPage extends StatefulWidget {
  const ScanEditPage({Key? key}) : super(key: key);

  @override
  _ScanEditPageState createState() => _ScanEditPageState();
}

class _ScanEditPageState extends State<ScanEditPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isTableVisible = false;  // This flag controls the visibility of the table
  bool _isDeviceSelected = false; // This flag controls the visibility of the Format button
  bool _isExtraFieldsVisible = false; // This flag controls the visibility of the extra fields and button
  List<BluetoothDevice> _deviceList  = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? rxCharacteristic;
  StreamSubscription<BluetoothDeviceState>? _connectionSubscription;
  final TextEditingController _lowThresholdController1 = TextEditingController();
  final TextEditingController _highThresholdController1 = TextEditingController();
  final TextEditingController _lowThresholdController2 = TextEditingController();
  final TextEditingController _highThresholdController2 = TextEditingController();
  final TextEditingController _lowThresholdController3 = TextEditingController();
  final TextEditingController _highThresholdController3 = TextEditingController();
  final TextEditingController wifissid = TextEditingController();
  final TextEditingController wifipass = TextEditingController();

  Future<void> sendData() async {
    // Get values from the text fields
    String lowThreshold1 = _lowThresholdController1.text;
    String highThreshold1 = _highThresholdController1.text;
    String lowThreshold2 = _lowThresholdController2.text;
    String highThreshold2 = _highThresholdController2.text;
    String lowThreshold3 = _lowThresholdController3.text;
    String highThreshold3 = _highThresholdController3.text;
    String wifii = wifissid.text;
    String pass = wifipass.text;
    bool err=false;
    // Append the values to the message
    String messagee = '{';




    if((lowThreshold1.isNotEmpty && highThreshold1.isEmpty)||(lowThreshold1.isEmpty && highThreshold1.isNotEmpty)
    ||(lowThreshold2.isNotEmpty && highThreshold2.isEmpty)||(lowThreshold2.isEmpty && highThreshold2.isNotEmpty)
        ||(lowThreshold3.isNotEmpty && highThreshold3.isEmpty)||(lowThreshold3.isEmpty && highThreshold3.isNotEmpty)
        ){
      err=true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to place both high and low threshold or leave both empty")),
      );
    }
    if((wifii.isNotEmpty && pass.isEmpty)||(wifii.isEmpty && pass.isNotEmpty)){
      err=true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to place both SSID and Password")),
      );
    }
    if(wifii.isEmpty && pass.isEmpty
        && highThreshold1.isEmpty && lowThreshold1.isEmpty
        && highThreshold2.isEmpty && lowThreshold2.isEmpty
        && highThreshold3.isEmpty && lowThreshold3.isEmpty
    ){
      err=true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No Data to be sent")),
      );
    }
    else{
    if(lowThreshold1.isNotEmpty && highThreshold1.isNotEmpty){

      // Convert strings to float (double in Dart)
      double? lowThreshold = double.tryParse(lowThreshold1);
      double? highThreshold = double.tryParse(highThreshold1);

      // Check if conversion was successful and if lowThreshold is less than highThreshold
      if (lowThreshold != null && highThreshold != null) {
        if (lowThreshold < highThreshold) {
          messagee += '"LOWS1": "$lowThreshold1", "HIGHS1": "$highThreshold1",';
        } else {
          // Show an error Snackbar
          err=true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Low threshold must be less than high threshold.")),
          );
        }
      } else {
        err=true;
        // Show an error Snackbar if conversion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Invalid number format.")),
        );
      }
    }
    if(lowThreshold2.isNotEmpty && highThreshold2.isNotEmpty){
      // Convert strings to float (double in Dart)
      double? lowThreshold = double.tryParse(lowThreshold2);
      double? highThreshold = double.tryParse(highThreshold2);

      // Check if conversion was successful and if lowThreshold is less than highThreshold
      if (lowThreshold != null && highThreshold != null) {
        if (lowThreshold < highThreshold) {
          messagee += '"LOWS2": "$lowThreshold2", "HIGHS2": "$highThreshold2",';
        } else {
          err=true;
          // Show an error Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Low threshold must be less than high threshold.")),
          );
        }
      } else {
        err=true;
        // Show an error Snackbar if conversion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Invalid number format.")),
        );
      }
    }
    if(lowThreshold3.isNotEmpty && highThreshold3.isNotEmpty){
      // Convert strings to float (double in Dart)
      double? lowThreshold = double.tryParse(lowThreshold3);
      double? highThreshold = double.tryParse(highThreshold3);

      // Check if conversion was successful and if lowThreshold is less than highThreshold
      if (lowThreshold != null && highThreshold != null) {
        if (lowThreshold < highThreshold) {
          messagee += '"LOWS3": "$lowThreshold3", "HIGHS3": "$highThreshold3",';
        } else {
          err=true;
          // Show an error Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Low threshold must be less than high threshold.")),
          );
        }
      } else {
        err=true;
        // Show an error Snackbar if conversion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Invalid number format.")),
        );
      }
    }
    if(wifii.isNotEmpty && pass.isNotEmpty){
      messagee+='"SSID": "$wifii", "Password": "$pass",';
    }
    messagee = messagee.substring(0, messagee.length - 1);
    messagee+='}';
    // Convert the message to bytes
    final bytes = utf8.encode(messagee);

    // Write the data to rxCharacteristic
    try {
      if(!err){
        await rxCharacteristic?.write(bytes, withoutResponse: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data sent successfully")),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send data: $e")),
      );
    }

    }
  }
  @override
  Widget build(BuildContext context) {
    // Example data for 10 devices

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async{
                  setState(() {
                    _isTableVisible = !_isTableVisible;
                    _deviceList.clear();
                  });


                  flutterBlue.stopScan();

                  // Get the list of connected devices and disconnect them
                  List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
                  for (BluetoothDevice device in connectedDevices) {
                    await device.disconnect();
                  }
                  // Start scanning
                  flutterBlue.startScan(timeout: const Duration(seconds: 5));

                  // Listen to scan results
                  flutterBlue.scanResults.listen((results) {
                    for (ScanResult r in results) {
                      if (r.device.name.isNotEmpty && !_deviceList.any((d) => d.id == r.device.id)) {
                        setState(() {
                          _deviceList.add(r.device);
                        });
                      }
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Scan BLE Devices'),
              ),

              const SizedBox(height: 20),

              // Show the table only if _isTableVisible is true
              if (_isTableVisible)
                Column(
                  children: [
                    // Table Header without Status column
                    Container(
                      color: Colors.green[900],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Row(
                        children: [
                          Expanded(child: Center(child: Text('Device Name', style: TextStyle(color: Colors.white)))),
                          Expanded(child: Center(child: Text('Action', style: TextStyle(color: Colors.white)))),
                        ],
                      ),
                    ),

                    // Scrollable Table Body - shows 5 rows at once, but scrolls if more
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: _deviceList.length,
                        itemBuilder: (context, index) {
                          final device = _deviceList[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                              color: Colors.grey.shade900,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      device.name.isNotEmpty ? device.name : 'Unknown Device',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () async {
                                        if (_connectedDevice != null) {
                                          // Already connected, so disconnect
                                          try {

                                            await _connectedDevice!.disconnect();
                                            setState(() {
                                              _connectedDevice = null;
                                              _isDeviceSelected = false;
                                              _isExtraFieldsVisible = false;
                                            });
                                          } catch (e) {
                                            print('Disconnection error: $e');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Disconnection failed: $e")),
                                            );
                                          }
                                        } else {
                                          // Connect

                                          try {
                                            await device.connect(autoConnect: false);
                                            List<BluetoothService> services = await device.discoverServices();
                                            final uuid1 = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
                                            final uuid2 = Guid("6E400002-B5A3-F393-E0A9-E50E24DFFA9E");



                                            for (BluetoothService service in services) {
                                              for (BluetoothCharacteristic characteristic in service.characteristics) {
                                                if (characteristic.uuid == uuid2 || characteristic.uuid == uuid1) {
                                                  rxCharacteristic = characteristic;
                                                  break;
                                                }
                                              }
                                              if (rxCharacteristic != null) break;
                                            }

                                            if (rxCharacteristic != null) {

                                              setState(() {
                                                _connectedDevice = device;

                                                // Set flags based on which UUID was matched
                                                if (rxCharacteristic!.uuid == uuid1) {
                                                  _isDeviceSelected = true;
                                                  _isExtraFieldsVisible = true;
                                                } else if (rxCharacteristic!.uuid == uuid2) {
                                                  _isExtraFieldsVisible = true;
                                                }
                                              });
                                            } else {
                                              await device.disconnect();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Required characteristic not found.")),
                                              );
                                            }
                                          } catch (e) {
                                            print('Connection error: $e');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Connection failed: $e")),
                                            );
                                          }
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                      child: Text(
                                        _connectedDevice == device ? 'Disconnect' : 'Connect',
                                        style: const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Orange Format Device button appears only after a device is selected
              if (_isDeviceSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed:  () async {
                      // Action for formatting the device
                      final message = '{"DandR":"OK"}';
                      final bytes = utf8.encode(message); // Convert string to bytes

                      await rxCharacteristic?.write(bytes, withoutResponse: false);

                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Format Device', style: TextStyle(color: Colors.white)),
                  ),
                ),

              // Row to display two images next to each other
              // Row to display two images next to each other
              if (_isDeviceSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      // Row to display two images next to each other
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // First Heater Image
                          Image.asset(
                            'assets/heater.jpg',
                            width: 200, // Set the width of the image
                            height: 200, // Set the height of the image
                            fit: BoxFit.cover, // Adjust the image to cover the box
                          ),
                          // Second Heater Image
                          Image.asset(
                            'assets/heater.jpg',
                            width: 200, // Set the width of the image
                            height: 200, // Set the height of the image
                            fit: BoxFit.cover, // Adjust the image to cover the box
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // Space between the images and the text fields

                      // Row to display two TextFields under the images (First row)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _lowThresholdController1,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Heater 1 Low threhsold',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                // SizedBox(height: 10), // Space between text fields
                                TextField(
                                  controller: _highThresholdController1,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Heater 1 High threhsold',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _lowThresholdController2,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Heater 2 Low threhsold',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                // SizedBox(height: 10), // Space between text fields
                                TextField(
                                  controller: _highThresholdController2,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Heater 2 High threhsold',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Full-width Image at the bottom (humidfan.jpg)
              if (_isDeviceSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Image.asset(
                    'assets/humidfan.jpg', // Your full-width image
                    width: double.infinity, // Make the image take up full width
                    fit: BoxFit.cover, // Make sure it covers the full width
                  ),
                ),

              // Row to display two TextFields under the humidfan image (Second row)
              if (_isDeviceSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _lowThresholdController3,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter Humidity Low threshold',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10), // Space between text fields
                      Expanded(
                        child: TextField(
                          controller: _highThresholdController3,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Enter Humidity High threshold',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),

              // Extra TextFields and Button under specific conditions
              if (_isExtraFieldsVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      // Full-width TextFields under each other
                      TextField(
                        controller: wifissid,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Wi-Fi SSID',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 10), // Space between text fields
                      TextField(
                        controller: wifipass,
                        textAlign: TextAlign.center,
                        obscureText: true, // <-- Hides the text input
                        decoration: InputDecoration(
                          hintText: 'Wi-Fi Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 20), // Space between text fields and the button

                      // Full-width Button
                      SizedBox(
                        width: double.infinity, // Ensure the button takes full width
                        child: ElevatedButton(
                          onPressed: () {
                            sendData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  String error = '';

  Future<void> login() async {
    final email = usernameController.text.trim().toLowerCase();;
    final password = passwordController.text;

    const token = 'oi0a8wuefofmxlnla61m';
    final url = 'https://demo.thingsboard.io/api/v1/$token/attributes?sharedKeys=$email';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final shared = data['shared'] ?? {};

        final storedPassword = shared[email];

        if (storedPassword != null && storedPassword == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          setState(() => error = 'Invalid email or password');
        }
      } else {
        setState(() => error = 'Failed to connect: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => error = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/logo.jpg',
                height: 180,
              ),
              const SizedBox(height: 120),
              Text(
                'Welcome to SSTM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                  setState(() => isLoading = true);
                  await login(); // your existing login logic here
                  setState(() => isLoading = false);
                },
                icon: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.login, color: Colors.white),
                label: Text(
                  isLoading ? 'Logging in...' : 'Login',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}