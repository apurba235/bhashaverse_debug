import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:bhashaverse_debug/app/common/snackbar.dart';
import 'package:bhashaverse_debug/app/data/api_base.dart';
import 'package:bhashaverse_debug/app/models/asr_translation_response.dart';
import 'package:bhashaverse_debug/app/models/asr_translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/language_models.dart';
import 'package:bhashaverse_debug/app/models/translation_models.dart';
import 'package:bhashaverse_debug/app/models/translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/transliteration_models.dart';
import 'package:bhashaverse_debug/app/models/transliteration_response.dart';
import 'package:bhashaverse_debug/app/models/tts_models.dart';
import 'package:bhashaverse_debug/app/utils/language_code.dart';
import 'package:bhashaverse_debug/app/utils/permission_handler.dart';
import 'package:bhashaverse_debug/app/utils/static_statements.dart';
import 'package:bhashaverse_debug/app/utils/voice_recorder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  RxBool ttsSwitch = RxBool(false);
  bool isMicPermissionGranted = false;
  final VoiceRecorder _voiceRecorder = VoiceRecorder();
  int samplingRate = 8000;
  final PlayerController _playerController = PlayerController();
  RxBool recordingOngoing = RxBool(false);
  Rxn<LanguageModels?> languages = Rxn<LanguageModels>();
  Rxn<TransliterationModels?> transliterationModels =
      Rxn<TransliterationModels>();
  Rxn<TransliterationResponse?> hints = Rxn<TransliterationResponse>();
  Rxn<TranslationResponse?> translatedResponse = Rxn<TranslationResponse>();
  Rxn<AsrTranslationResponse?> asrTranslatedResponse =
      Rxn<AsrTranslationResponse>();
  Rxn<TtsResponse?> ttsResponse = Rxn<TtsResponse>();
  Rxn<AsrTranslationTtsResponse?> asrTranslationTts =
      Rxn<AsrTranslationTtsResponse>();
  Rxn<TranslationTtsResponse?> translationTtsResponse =
      Rxn<TranslationTtsResponse>();
  RxnString sourceLang = RxnString();
  RxnString targetLang = RxnString();
  bool fromSourceLangButton = true;
  int sourceLangIndex = -1;
  Timer? countDown;
  RxInt configApiCallTime = RxInt(0);
  RxInt computeApiCallTime = RxInt(0);
  RxString selectedPipeline = RxString('64392f96daac500b55c543cd');
  String computeURL = '';
  String computeApiKey = '';
  String computeApiValue = '';
  String asrServiceId = "";
  String translationId = "";
  String ttsId = "";
  String input = '';
  String transliterationInput = '';
  RxnString generatedInput = RxnString();
  RxnString output = RxnString();
  String encodedAudio = '';
  String ttsFilePath = '';
  late TextEditingController inputController;
  List<String> pipelineIds = [
    '64392f96daac500b55c543cd',
    '643930aa521a4b1ba0f4c41d'
  ];
  RxBool languageLoader = RxBool(false);
  RxBool computationLoader = RxBool(false);
  RxBool ttsComputeLoader = RxBool(false);
  RxString selectedPipelineName = RxString('MEITY');
  RxBool playTTs = RxBool(false);
  RxString transliterationModelId = RxString('');
  RxString exampleStatement = RxString('Example sentences');
  Rx<List<String>> examples = Rx<List<String>>([]);
  RxBool enableTranslate = RxBool(false);
  RxBool enablePlayPauseButton = RxBool(false);

  void resetFields([bool both = false]) {
    input = '';
    inputController.text = '';
    generatedInput.value = null;
    output.value = null;
    encodedAudio = '';
    ttsFilePath = '';
    computeApiCallTime.value = 0;
    hints.value = null;
    examples.value = [];
    exampleStatement.value = 'Example sentences';
    asrServiceId = '';
    translationId = '';
    ttsId = '';
    if (both) {
      sourceLang.value = null;
      targetLang.value = null;
    }
  }

  void resetOutputRelatedFields() {
    output.value = null;
    ttsFilePath = '';
    computeApiCallTime.value = 0;
  }

  void selectStatementAsInput() {
    bool setBlanck = false;
    examples.value = StaticStatements.staticList.entries
        .firstWhere((element) => element.key == sourceLang.value, orElse: () {
      setBlanck = true;
      return const MapEntry('', ['']);
    }).value;
    if (setBlanck) {
      examples.value = [];
    }
  }

  Future<void> performComputation() async {
    if (ttsSwitch.value && encodedAudio.isNotEmpty) {
      await computeAsrTranslationTts();
      enablePlayButton();
    } else if (ttsSwitch.value && encodedAudio.isEmpty && input.isNotEmpty) {
      await computeTranslationTts();
      enablePlayButton();
    } else if (ttsSwitch.value == false && encodedAudio.isNotEmpty) {
      await computeAsrTranslation();
      enablePlayButton();
    } else if (ttsSwitch.value == false &&
        encodedAudio.isEmpty &&
        input.isNotEmpty) {
      await computeTranslation();
      enablePlayButton();
    }
  }

  void enableTranslateButton() {
    if ((sourceLang.value?.isNotEmpty ?? false) &&
        (targetLang.value?.isNotEmpty ?? false) &&
        ((input.isNotEmpty) || (encodedAudio.isNotEmpty))) {
      enableTranslate.value = true;
    } else {
      enableTranslate.value = false;
    }
  }

  void enablePlayButton() {
    if ((output.value?.isNotEmpty ?? false) || (ttsFilePath.isNotEmpty)) {
      enablePlayPauseButton.value = true;
    } else {
      enablePlayPauseButton.value = false;
    }
  }

  void getPipelineName() {
    if (selectedPipeline.value == pipelineIds[0]) {
      selectedPipelineName.value = "MEITY";
    } else if (selectedPipeline.value == pipelineIds[1]) {
      selectedPipelineName.value = "AI4B";
    }
  }

  void startRecording() async {
    await PermissionHandler.requestPermissions().then((result) {
      isMicPermissionGranted = result;
    });
    if (isMicPermissionGranted) {
      generatedInput.value = 'Please type something to translate';
      output.value = 'Output will be here';
      recordingOngoing.value = true;
      input = '';
      // await _voiceRecorder.clearOldRecordings();
      await _voiceRecorder.startRecordingVoice(samplingRate);
    }
  }

  void stopRecordingAndGetResult() async {
    recordingOngoing.value = false;
    encodedAudio = await _voiceRecorder.stopRecordingVoiceAndGetOutput() ?? '';
    enableTranslateButton();
    performComputation();
  }

  Future<void> playRecordedAudio(String filePath) async {
    playTTs.value = true;
    if (_playerController.playerState == PlayerState.playing ||
        _playerController.playerState == PlayerState.paused) {
      await _playerController.stopPlayer();
    }
    await _playerController.preparePlayer(
      path: filePath,
      shouldExtractWaveform: false,
    );
    await _playerController.startPlayer(finishMode: FinishMode.pause);
    await Future.delayed(Duration(milliseconds: _playerController.maxDuration));
    playTTs.value = false;
  }

  void getTransliterationInput() {
    int index = 0;
    for (int i = input.length - 1; i >= 0; i--) {
      if (input[i].contains(RegExp('[^A-Za-z]'))) {
        index = i + 1;
        break;
      }
    }
    transliterationInput = input.substring(index);
  }

  Future<void> getTransliterationModels() async {
    TransliterationModels? response =
        await ApiCall.instance.getTransliterationModels();
    if (response != null) {
      transliterationModels.value = response;
    }
  }

  Future<void> computeTransliteration() async {
    TransliterationResponse? response = await ApiCall.instance
        .computeTransliteration(
            transliterationModelId.value, transliterationInput);
    if (response != null) {
      hints.value = response;
    } else {
      await showSnackBar();
    }
    hints.value?.output?.first.target?.forEach((element) {
      log(element, name: 'Hints');
    });
  }

  Future<void> getLanguages() async {
    languageLoader.value = true;
    configApiCallTime.value = 0;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        configApiCallTime.value += 1;
      },
    );
    LanguageModels? response =
        await ApiCall.instance.getLanguages(selectedPipeline.value);
    countDown?.cancel();
    log(configApiCallTime.value.toString(), name: 'time check');
    if (response != null) {
      languages.value = response;
    } else {
      await showSnackBar();
    }
    languageLoader.value = false;
  }

  Future<void> computeAsrTranslationTts() async {
    computeApiCallTime.value = 0;
    computationLoader.value = true;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        computeApiCallTime.value += 1;
      },
    );
    AsrTranslationTtsResponse? response = await ApiCall.instance
        .computeAsrTranslationTts(
            computeURL,
            sourceLang.value ?? '',
            targetLang.value ?? '',
            encodedAudio,
            asrServiceId,
            translationId,
            ttsId);
    if (response != null) {
      asrTranslationTts.value = response;
    } else {
      await showSnackBar();
    }
    computationLoader.value = false;
    countDown?.cancel();
    encodedAudio = '';
    generatedInput.value = asrTranslationTts.value?.pipelineResponse
        ?.firstWhere((element) => element.taskType == 'translation')
        .output
        ?.first
        .source;
    inputController.text = generatedInput.value ?? '';
    output.value = asrTranslationTts.value?.pipelineResponse
        ?.firstWhere((element) => element.taskType == 'translation')
        .output
        ?.first
        .target;
    String generatedAudio = asrTranslationTts.value?.pipelineResponse
            ?.firstWhere((element) => element.taskType == 'tts')
            .audio
            ?.first
            .audioContent ??
        '';
    writeTTsAudio(generatedAudio);
  }

  Future<void> computeAsrTranslation() async {
    computeApiCallTime.value = 0;
    computationLoader.value = true;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        computeApiCallTime.value += 1;
      },
    );
    AsrTranslationResponse? response = await ApiCall.instance
        .computeAsrTranslation(computeURL, sourceLang.value ?? '',
            targetLang.value ?? '', encodedAudio, asrServiceId, translationId);
    if (response != null) {
      asrTranslatedResponse.value = response;
    } else {
      await showSnackBar();
    }
    computationLoader.value = false;
    countDown?.cancel();
    encodedAudio = '';
    generatedInput.value = asrTranslatedResponse.value?.pipelineResponse
        ?.firstWhere((element) => element.taskType == 'translation')
        .output
        ?.first
        .source;
    inputController.text = generatedInput.value ?? '';
    output.value = asrTranslatedResponse.value?.pipelineResponse
        ?.firstWhere((element) => element.taskType == 'translation')
        .output
        ?.first
        .target;
    ttsFilePath = '';
  }

  Future<void> computeTranslationTts() async {
    computeApiCallTime.value = 0;
    computationLoader.value = true;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        computeApiCallTime.value += 1;
      },
    );
    TranslationTtsResponse? response = await ApiCall.instance
        .computeTranslationTts(computeURL, sourceLang.value ?? '',
            targetLang.value ?? '', input, translationId, ttsId);
    if (response != null) {
      translationTtsResponse.value = response;
    } else {
      await showSnackBar();
    }
    computationLoader.value = false;
    countDown?.cancel();
    output.value = translationTtsResponse.value?.pipelineResponse
        ?.firstWhere((element) => element.taskType == 'translation')
        .output
        ?.first
        .target;
    String generatedOutput = translationTtsResponse.value?.pipelineResponse
            ?.firstWhere((element) => element.taskType == 'tts')
            .audio
            ?.first
            .audioContent ??
        '';
    writeTTsAudio(generatedOutput);
  }

  Future<void> computeTranslation() async {
    computeApiCallTime.value = 0;
    computationLoader.value = true;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        computeApiCallTime.value += 1;
      },
    );
    TranslationResponse? response = await ApiCall.instance.computeTranslation(
        computeURL,
        sourceLang.value ?? '',
        targetLang.value ?? '',
        input,
        translationId);
    countDown?.cancel();
    if (response != null) {
      translatedResponse.value = response;
    } else {
      await showSnackBar();
    }
    computationLoader.value = false;
    output.value = translatedResponse
            .value?.pipelineResponse?.first.output?.first.target ??
        '';
    ttsFilePath = '';
  }

  Future<void> computeTts() async {
    computeApiCallTime.value = 0;
    ttsComputeLoader.value = true;
    countDown = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        computeApiCallTime.value += 1;
      },
    );
    TtsResponse? response = await ApiCall.instance.generateTTS(
        computeURL, targetLang.value ?? '', output.value ?? '', ttsId);
    countDown?.cancel();
    if (response != null) {
      ttsResponse.value = response;
    } else {
      await showSnackBar();
    }
    ttsComputeLoader.value = false;
    String audioTts =
        response?.pipelineResponse?.first.audio?.first.audioContent ?? '';
    await writeTTsAudio(audioTts);
    await playRecordedAudio(ttsFilePath);
  }

  Future<void> writeTTsAudio(String audioContent) async {
    Uint8List? fileAsBytes = base64Decode(audioContent);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String recordingPath = '${appDocDir.path}/recordings';
    if (!await Directory(recordingPath).exists()) {
      Directory(recordingPath).create();
    }
    ttsFilePath =
        '$recordingPath/TTSAudio${DateTime.now().millisecondsSinceEpoch}.wav';
    File? ttsAudioFile = File(ttsFilePath);
    await ttsAudioFile.writeAsBytes(fileAsBytes);
  }

  void computeApiData() {
    computeURL =
        languages.value?.pipelineInferenceAPIEndPoint?.callbackUrl ?? '';
    computeApiKey =
        languages.value?.pipelineInferenceAPIEndPoint?.inferenceApiKey?.name ??
            '';
    computeApiValue =
        languages.value?.pipelineInferenceAPIEndPoint?.inferenceApiKey?.value ??
            '';
    ApiCall.instance.generateComputeHeader(computeApiKey, computeApiValue);
  }

  void getAsrServiceId() {
    asrServiceId = languages.value?.pipelineResponseConfig
            ?.firstWhere((element) => element.taskType == 'asr')
            .config
            ?.firstWhere((e) =>
                e.language?.sourceLanguage?.contains(sourceLang) ?? false)
            .serviceId ??
        "";
    log(asrServiceId, name: 'Asr Service  ID');
  }

  void getTranslationAndTtsId() {
    translationId = languages.value?.pipelineResponseConfig
            ?.firstWhere((element) => element.taskType == 'translation')
            .config
            ?.firstWhere((e) =>
                ((e.language?.sourceLanguage?.contains(sourceLang) ?? false) &&
                    (e.language?.targetLanguage?.contains(targetLang) ??
                        false)))
            .serviceId ??
        "";
    ttsId = languages.value?.pipelineResponseConfig
            ?.firstWhere((element) => element.taskType == 'tts')
            .config
            ?.firstWhere((e) =>
                (e.language?.sourceLanguage?.contains(targetLang) ?? false))
            .serviceId ??
        "";
    log(translationId, name: 'Translation Service  ID');
    log(ttsId, name: 'TTS Service  ID');
  }

  void getTransliterationModelId() {
    transliterationModelId.value = transliterationModels.value?.data
            ?.firstWhere(
              (element) => ((element.languages?.first.sourceLanguage == 'en') &&
                  (element.languages?.first.targetLanguage ==
                      sourceLang.value)),
              orElse: () => Data(modelId: ''),
            )
            .modelId ??
        '';
    log(transliterationModelId.value, name: 'Transliteration Model Id');
  }

  @override
  void onInit() async {
    inputController = TextEditingController();
    await getLanguages();
    computeApiData();
    await getTransliterationModels();
    await _voiceRecorder.clearOldRecordings();
    super.onInit();
  }

  String getLanguageName(String code) => LanguageCode.languageCode.entries
      .where((element) => element.key == code)
      .first
      .value;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void onDispose() {
    inputController.dispose();
    super.dispose();
  }
}
