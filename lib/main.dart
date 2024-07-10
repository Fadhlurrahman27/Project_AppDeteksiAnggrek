import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(TeachableMachineApp());
}

class TeachableMachineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teachable Machine Classification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TeachableMachineScreen(),
    );
  }
}

class TeachableMachineScreen extends StatefulWidget {
  @override
  _TeachableMachineScreenState createState() => _TeachableMachineScreenState();
}

class _TeachableMachineScreenState extends State<TeachableMachineScreen> {
  late File _image;
  late List _output;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachable Machine Classification'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null ? Image.file(_image) : const Placeholder(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 16),
          _output != null
              ? Text(
                  'Prediction: ${_output[0]['label']} (${_output[0]['confidence'].toStringAsFixed(2)})',
                  style: const TextStyle(fontSize: 20),
                )
              : const Placeholder(),
        ],
      ),
    );
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
    print('Model loaded: $res');
  }

  void pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _image = File(image.path);
      classifyImage(_image);
    });
  }

  Future<void> classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.1,
    );
    setState(() {
      _output = output!;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
