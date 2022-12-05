import 'package:a_eye/ui/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';

class VoiceScreen extends StatefulWidget {
  VoiceScreen({Key? key}) : super(key: key);

  @override
  VoiceScreenState createState() => VoiceScreenState();
}

class VoiceScreenState extends State<VoiceScreen> {
  final SpeechToText _speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  late TtsState ttsState;
  bool _speechEnabled = false;
  String _lastWords = '';

  Future _speak(String speakString) async {
    var result = await flutterTts.speak(speakString);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    Future.delayed(Duration(seconds: 1), () async {
      if (result.recognizedWords.contains('Scan') ||
          result.recognizedWords.contains('scan')) {
        _speak('You will be directed to the currency detection page');
        await flutterTts.awaitSpeakCompletion(true);
        Future<void> navigationPage() async {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TabViewScreen()));
        }
      }
      // } else if (result.recognizedWords.contains('s o s') ||
      //     result.recognizedWords.contains('S O S')) {
      //   _speak(
      //       'You will be directed to the S O S page please enter information accurately');
      //   await flutterTts.awaitSpeakCompletion(true);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision'),
      ),
      body: Center(
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Container(
        //       padding: EdgeInsets.all(16),
        //       child: Text(
        //         'Recognized words:',
        //         style: TextStyle(fontSize: 20.0),
        //       ),
        //     ),
        child: Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Text(
              // If listening is active show the recognized words
              _speechToText.isListening
                  ? '$_lastWords'
                  // If listening isn't active but could be tell the user
                  // how to start it, otherwise indicate that speech
                  // recognition is not yet ready or not supported on
                  // the target device
                  : _speechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(
          heightFactor: 40,
          widthFactor: 40,
          child: FloatingActionButton(
            onPressed:
                // If not yet listening for speech start, otherwise stop
                _speechToText.isNotListening ? _startListening : _stopListening,
            tooltip: 'Listen',
            child:
                Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          ),
        ),
      ),
    );
  }
}
