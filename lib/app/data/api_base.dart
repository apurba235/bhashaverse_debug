import 'dart:developer';

import 'package:bhashaverse_debug/app/models/asr_translation_response.dart';
import 'package:bhashaverse_debug/app/models/asr_translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/language_models.dart';
import 'package:bhashaverse_debug/app/models/translation_models.dart';
import 'package:bhashaverse_debug/app/models/translation_tts_response.dart';
import 'package:bhashaverse_debug/app/models/transliteration_models.dart';
import 'package:bhashaverse_debug/app/models/transliteration_response.dart';
import 'package:bhashaverse_debug/app/models/tts_models.dart';
import 'package:dio/dio.dart';

///

/// Delete enum add on 28 sept
enum RestApiMethod { get, put, post, delete }

class ApiBase {
  Dio dio = Dio();

  Future<Map<String, dynamic>?> _restApi<T>(
    String path, {
    String? baseUrl,
    required RestApiMethod apiMethod,
    Map<String, dynamic>? headers,
    dynamic body = const {},
    bool isBearerToken = false,

    ///[attachToken] is for defining whether to attach token in the header or not
    bool attachToken = true,
    bool showError = true,
  }) async {
    try {
      if (baseUrl != null) {
        ///if user chooses to send a different base url
        dio.options.baseUrl = baseUrl;
      }

      ///logging the POST endpoint and PAYLOAD
      log('${dio.options.baseUrl}$path', name: '$apiMethod');
      if (body is! FormData) log(body.toString(), name: "PAYLOAD");


      ///Hitting the POST request
      Response<T>? response;
      switch (apiMethod) {
        case RestApiMethod.post:
          response = await dio.post(
            path,
            data: body,
            options: Options(headers: headers),
            // options: attachToken
            //     ? Options(headers: header)
            //     : null,
          );
          break;
        default:
          break;
      }

      ///logging the RESPONSE details
      // log('${response?.data}', name: "RESPONSE");
      log('${response?.statusCode}', name: "RESPONSE STATUS CODE");

      ///if nor error then return response else return NUll
      if (response?.data is Map?) {
        Map<String, dynamic>? x = response?.data as Map<String, dynamic>?;
        if (x != null && (x['status'] != false)) {
          return x;
        } else {
          if (showError) {
            String errorMessage = '${x?['message'].toString()}';
            if (!errorMessage.contains('SocketException') &&
                !errorMessage.contains('HttpException')) {
              // showSnackBar(errorMessage, isError: true);
            } else {
              // showSnackBar('Something went wrong!', isError: true);
            }
          }
        }
      }
    } on DioError catch (e) {
      ///if exception show the error
      log('${e.response}', name: 'DIO EXCEPTION');
      if (showError) {
        if (!e.toString().contains('SocketException') &&
            !e.toString().contains('HttpException')) {
          // this.showError(e);
        } else {
          // showSnackBar('Something went wrong!', isError: true);
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> postApi<T>(
    String path, {
    String? baseUrl,
    required dynamic body,
    bool isBearerToken = false,
    bool attachToken = true,
    bool showError = true,
    Map<String, dynamic>? header,
  }) async {
    return await _restApi(
      path,
      baseUrl: baseUrl,
      body: body,
      attachToken: attachToken,
      isBearerToken: isBearerToken,
      apiMethod: RestApiMethod.post,
      showError: showError,
      headers: header,
    );
  }
}

///

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
