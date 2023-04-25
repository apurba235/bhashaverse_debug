import 'package:bhashaverse_debug/app/data/api_base.dart';
import 'package:bhashaverse_debug/app/models/asr_translation_response.dart';
import 'package:bhashaverse_debug/app/models/asr_translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/language_models.dart';
import 'package:bhashaverse_debug/app/models/translation_models.dart';
import 'package:bhashaverse_debug/app/models/translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/transliteration_models.dart';
import 'package:bhashaverse_debug/app/models/transliteration_response.dart';
import 'package:bhashaverse_debug/app/models/tts_models.dart';

class ApiCall extends ApiBase {
  ApiCall._();

  static ApiCall instance = ApiCall._();

  var configHeader = {
    'userID': '965355806bf84442a8a168259ed8c06f',
    'ulcaApiKey': '4209d60edc-70e5-4b71-8427-c4665743e909'
  };

  late Map<String, dynamic> computeHeader;

  void generateComputeHeader(String key, String value) {
    computeHeader = {
      'Accept': '*/*',
      'User-Agent': ' Thunder Client (https://www.thunderclient.com)',
      key: value
    };
  }

  static const getModelsURL =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline';

  static const searchModelTransliteration =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/search';

  static const computeTransliterationUrl =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/compute';

  Future<LanguageModels?> getLanguages(String pipelineId) async {
    Map<String, dynamic>? response = await postApi(
      getModelsURL,
      body: {
        "pipelineTasks": [
          {"taskType": "asr"},
          {"taskType": "translation"},
          {"taskType": "tts"}
        ],
        "pipelineRequestConfig": {"pipelineId": pipelineId}
      },
      header: configHeader,
    );
    return (response == null) ? null : LanguageModels.fromJson(response);
  }

  /// only for Asr, Translation and Tts i.e. from audio generate translation in target language and generate speech in target language.
  Future<AsrTranslationTtsResponse?> computeAsrTranslationTts(
      String apiUrl,
      String sourceLang,
      String targetLang,
      String audioInput,
      String asrId,
      String translationId,
      String ttsId) async {
    Map<String, dynamic>? response = await postApi(
      apiUrl,
      body: {
        "pipelineTasks": [
          {
            "taskType": "asr",
            "config": {
              "language": {"sourceLanguage": sourceLang},
              "serviceId": asrId,
              "audioFormat": "wav",
              "samplingRate": 16000
            }
          },
          {
            "taskType": "translation",
            "config": {
              "language": {
                "sourceLanguage": sourceLang,
                "targetLanguage": targetLang
              },
              "serviceId": translationId
            }
          },
          {
            "taskType": "tts",
            "config": {
              "language": {"sourceLanguage": targetLang},
              "gender": "female",
              "serviceId": ttsId
            }
          }
        ],
        "inputData": {
          "audio": [
            {"audioContent": audioInput}
          ]
        }
      },
      header: computeHeader,
    );
    return response == null
        ? null
        : AsrTranslationTtsResponse.fromJson(response);
  }

  /// only for Asr and Translation i.e. from audio generate translation in target language.
  Future<AsrTranslationResponse?> computeAsrTranslation(
      String apiUrl,
      String sourceLang,
      String targetLang,
      String audioInput,
      String asrId,
      String translationId) async {
    Map<String, dynamic>? response = await postApi(
      apiUrl,
      body: {
        "pipelineTasks": [
          {
            "taskType": "asr",
            "config": {
              "language": {"sourceLanguage": sourceLang},
              "serviceId": asrId,
              "audioFormat": "wav",
              "samplingRate": 16000
            }
          },
          {
            "taskType": "translation",
            "config": {
              "language": {
                "sourceLanguage": sourceLang,
                "targetLanguage": targetLang
              },
              "serviceId": translationId
            }
          }
        ],
        "inputData": {
          "audio": [
            {"audioContent": audioInput}
          ]
        }
      },
      header: computeHeader,
    );
    return response == null ? null : AsrTranslationResponse.fromJson(response);
  }

  /// only for Translation and Tts i.e. from text input generate translation in target language and generate speech in target language.
  Future<TranslationTtsResponse?> computeTranslationTts(
      String apiUrl,
      String sourceLang,
      String targetLang,
      String input,
      String translationId,
      String ttsId) async {
    Map<String, dynamic>? response = await postApi(
      apiUrl,
      body: {
        "pipelineTasks": [
          {
            "taskType": "translation",
            "config": {
              "language": {
                "sourceLanguage": sourceLang,
                "targetLanguage": targetLang
              },
              "serviceId": translationId
            }
          },
          {
            "taskType": "tts",
            "config": {
              "language": {"sourceLanguage": targetLang},
              "serviceId": ttsId,
              "gender": "female"
            }
          }
        ],
        "inputData": {
          "input": [
            {"source": input}
          ]
        }
      },
      header: computeHeader,
    );
    return response == null ? null : TranslationTtsResponse.fromJson(response);
  }

  /// only for Translation i.e. giving Text input and getting translated text.
  Future<TranslationResponse?> computeTranslation(
      String apiUrl,
      String sourceLang,
      String targetLang,
      String input,
      String translationId) async {
    Map<String, dynamic>? response = await postApi(
      apiUrl,
      body: {
        "pipelineTasks": [
          {
            "taskType": "translation",
            "config": {
              "language": {
                "sourceLanguage": sourceLang,
                "targetLanguage": targetLang
              },
              "serviceId": translationId
            }
          }
        ],
        "inputData": {
          "input": [
            {"source": input}
          ]
        }
      },
      header: computeHeader,
    );
    return response == null ? null : TranslationResponse.fromJson(response);
  }

  /// only for Tts i.e. from translated Text output generate speech in target language.
  Future<TtsResponse?> generateTTS(
      String apiUrl, String sourceLang, String input, String ttsId) async {
    Map<String, dynamic>? response = await postApi(
      apiUrl,
      body: {
        "pipelineTasks": [
          {
            "taskType": "tts",
            "config": {
              "language": {"sourceLanguage": sourceLang},
              "serviceId": ttsId,
              "gender": "female"
            }
          }
        ],
        "inputData": {
          "input": [
            {"source": input}
          ]
        }
      },
      header: computeHeader,
    );
    return response == null ? null : TtsResponse.fromJson(response);
  }

  Future<TransliterationModels?> getTransliterationModels() async {
    Map<String, dynamic>? response = await postApi(
      ApiCall.searchModelTransliteration,
      body: {
        "task": "transliteration",
        "sourceLanguage": "",
        "targetLanguage": "",
        "domain": "All",
        "submitter": "All",
        "userId": null
      },
    );
    return response == null ? null : TransliterationModels.fromJson(response);
  }

  Future<TransliterationResponse?> computeTransliteration(
      String modelId, String input) async {
    Map<String, dynamic>? response = await postApi(
      ApiCall.computeTransliterationUrl,
      body: {
        "modelId": modelId,
        "task": "transliteration",
        "input": [
          {"source": input}
        ]
      },
    );
    return response == null ? null : TransliterationResponse.fromJson(response);
  }
}