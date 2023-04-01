import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

//file to store audio
final pathToSaveAudio = 'temp_audio.mp3';

class SoundRecorder {
   FlutterSoundRecorder? _myRecorder = FlutterSoundRecorder();

   bool _isRecorderInitialised = false;
   bool get isRecording => _myRecorder!.isRecording;

   Future init() async {
    _myRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status!= PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission required for spoken conversation');
    }

    await _myRecorder!.openRecorder();
    _isRecorderInitialised = true;
   }

   void dispose() {
    if (!_isRecorderInitialised) return;

    _myRecorder!.closeRecorder();
    _myRecorder = null; 
    _isRecorderInitialised = false;
   }
   
   Future<void> _record() async {
    if (!_isRecorderInitialised) return;

    await _myRecorder!.startRecorder(
      toFile: 'temp_audio.mp3',
      codec: Codec.aacADTS,
    );
  }


  Future<void> _stopRecorder() async {
    if (!_isRecorderInitialised) return;

    await _myRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_myRecorder!.isStopped) {
      await _record();
    } else {
      await _stopRecorder();
    }
  }
}