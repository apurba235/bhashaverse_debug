import 'package:bhashaverse_debug/app/consts/colorconst.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class SourceTargetLanguageView extends GetView<HomeController> {
  const SourceTargetLanguageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.honeyDew,
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              ...List.generate(
                (controller.fromSourceLangButton)
                    ? controller.languages.value?.languages?.length ?? 0
                    : controller
                            .languages
                            .value
                            ?.languages?[controller.sourceLangIndex]
                            .targetLanguageList
                            ?.length ??
                        0,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      if (controller.fromSourceLangButton) {
                        controller.sourceLang.value = controller.languages.value
                                ?.languages?[index].sourceLanguage ??
                            '';
                        controller.targetLang.value = '';
                        controller.sourceLangIndex = index;
                        controller.getAsrServiceId();
                        controller.getTransliterationModelId();
                        controller.resetFields();
                        controller.selectStatementAsInput();
                      } else {
                        controller.targetLang.value = controller
                            .languages
                            .value
                            ?.languages?[controller.sourceLangIndex]
                            .targetLanguageList?[index];
                        controller.getTranslationAndTtsId();
                        controller.resetOutputRelatedFields();
                      }
                      Get.back();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(15),
                            child: controller.fromSourceLangButton
                                ? Text(
                                    controller.getLanguageName(controller
                                            .languages
                                            .value
                                            ?.languages?[index]
                                            .sourceLanguage ??
                                        ''),
                                  )
                                : Text(
                                    controller.getLanguageName(controller
                                            .languages
                                            .value
                                            ?.languages?[
                                                controller.sourceLangIndex]
                                            .targetLanguageList?[index] ??
                                        ''),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          );
        }),
      ),
    );
  }
}
