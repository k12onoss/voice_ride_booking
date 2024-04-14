import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechCubit extends Cubit<String> {
  final SpeechToText _speechToText;

  SpeechCubit(this._speechToText) : super("");

  Future<void> initialize() async => await _speechToText.initialize();

  Future<void> listen() async {
    if (_speechToText.isAvailable) {
      await _speechToText.listen(
        onResult: (result) {
          emit(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(listenMode: ListenMode.search),
      );
    }
  }

  Future<void> cancel() async => await _speechToText.cancel();

  Future<void> stop() async {
    await _speechToText.stop();
    emit("");
  }
}
