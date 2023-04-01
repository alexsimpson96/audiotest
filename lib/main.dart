import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:whispertest2/sound_recorder.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


//whisper API request
Future<String> transcribeAudio(String filePath) async {

  const apiKey = "";
  var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
  var request=http.MultipartRequest('POST', url);
  request.headers.addAll(({
    "Authorization": "Bearer $apiKey"}));
    request.fields["model"] = 'whisper-1';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();
  var newresponse = await http.Response.fromStream(response);
  final responseData = json.decode(newresponse.body);

  if (newresponse.statusCode == 200) {
    //print('API Output: ${responseData['text']}');
    return responseData['text'];

  } else {
    print('Error: ${responseData}');
    return 'Error occurred during transcription';
  }
  }


class _MyHomePageState extends State<MyHomePage> {

final recorder = SoundRecorder();
  
  // voice recording functions
  String transcription = '';

  @override
  void initState() {
    super.initState();
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();

    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) { // != means not null
                // call openai's transctiption api
                transcribeAudio(result.files.single.path!).then((value) {
                  setState(() {
                    transcription = value;
                  });
                });
              }
            },
            child: Text("Pick file"),
          ),
          Text(
            "Speech to Text:" + transcription,
            style: TextStyle(fontSize: 20),
          ),
          //recording button
          ElevatedButton(
            onPressed: () async {
              final isRecording = await recorder.toggleRecording();
              setState(() {});
            },
            child: Icon(
              recorder.isRecording ? Icons.mic : Icons.mic_none,
            ),
          ),
        ],
      ),
    ),
  );
}
}