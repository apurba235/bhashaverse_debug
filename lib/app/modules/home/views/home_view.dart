import 'package:bhashaverse_debug/app/consts/colorconst.dart';
import 'package:bhashaverse_debug/app/modules/home/views/source_target_language_view.dart';
import 'package:bhashaverse_debug/graphics/source_target_language_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.honeyDew,
      appBar: AppBar(
        title: const Text(
          'Bhashaverse Debug Version',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: ColorConst.honeyDew,
        elevation: 0,
      ),
      body: Obx(() {
        return controller.languageLoader.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: SizedBox(
                  height: Get.height * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              return Text(
                                controller.selectedPipelineName.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              );
                            }),
                            const SizedBox(width: 15),
                            Obx(() {
                              return Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                  ),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    isDense: true,
                                    value: controller.selectedPipeline.value,
                                    items: [
                                      ...List.generate(
                                        controller.pipelineIds.length,
                                        (index) => DropdownMenuItem(
                                          value: controller.pipelineIds[index],
                                          child: Text(
                                              controller.pipelineIds[index]),
                                        ),
                                      )
                                    ],
                                    onChanged: (v) {
                                      controller.selectedPipeline.value =
                                          v ?? '';
                                      controller.getPipelineName();
                                      controller.getLanguages();
                                      controller.resetFields(true);
                                      controller.transliterationModelId.value =
                                          '';
                                    },
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            return Expanded(
                              child: SourceTargetLanguageButton(
                                onTap: () {
                                  controller.fromSourceLangButton = true;
                                  Get.to(
                                    () => const SourceTargetLanguageView(),
                                  );
                                },
                                title:
                                    (controller.sourceLang.value?.isNotEmpty ??
                                            false)
                                        ? controller.getLanguageName(
                                            controller.sourceLang.value ?? '')
                                        : 'Source',
                              ),
                            );
                          }),
                          const Text(
                            'to',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Obx(() {
                            return Expanded(
                              child: SourceTargetLanguageButton(
                                onTap: () {
                                  controller.fromSourceLangButton = false;
                                  if (controller.sourceLang.isNotEmpty ??
                                      false) {
                                    Get.to(
                                      () => const SourceTargetLanguageView(),
                                    );
                                  }
                                },
                                title:
                                    (controller.targetLang.value?.isNotEmpty ??
                                            false)
                                        ? controller.getLanguageName(
                                            controller.targetLang.value ?? '')
                                        : 'Target',
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(border: Border.all()),
                          child: DropdownButton(
                            isExpanded: true,
                            isDense: true,
                            itemHeight: null,
                            hint: Text(controller.exampleStatement.value),
                            items: [
                              ...List.generate(
                                controller.examples.value.length,
                                (index) => DropdownMenuItem(
                                  value: controller.examples.value[index],
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xffb9e9fc)
                                            .withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 5.0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Text(
                                      controller.examples.value[index],
                                      style: const TextStyle(
                                          overflow: TextOverflow.visible),
                                    ),
                                  ),
                                ),
                              )
                            ],
                            onChanged: (v) {
                              controller.exampleStatement.value = v ?? '';
                              controller.inputController.text = v ?? '';
                              controller.input = v ?? '';
                              controller.output.value = null;
                              controller.ttsFilePath = '';
                              controller.enableTranslateButton();
                              controller.enablePlayButton();
                            },
                          ),
                        );
                      }),
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Auto TTS',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 15),
                            Switch(
                              value: controller.ttsSwitch.value,
                              onChanged: (value) {
                                controller.ttsSwitch.value = value;
                                if ((controller.sourceLang.value?.isNotEmpty ??
                                        false) &&
                                    (controller.targetLang.value?.isNotEmpty ??
                                        false)) {
                                  controller.performComputation();
                                }
                              },
                            ),
                          ],
                        );
                      }),
                      Obx(() {
                        return SizedBox(
                          height: controller.transliterationModelId.isNotEmpty
                              ? 30
                              : 0,
                          width: controller.transliterationModelId.isNotEmpty
                              ? Get.width
                              : 0,
                          child: Obx(() {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...List.generate(
                                    controller.hints.value?.output?.first.target
                                            ?.length ??
                                        0,
                                    (index) {
                                      final data = controller.hints.value
                                              ?.output?.first.target?[index] ??
                                          '';
                                      return GestureDetector(
                                        onTap: () {
                                          String temp =
                                              controller.inputController.text;
                                          String output = temp.replaceAll(
                                              RegExp('[A-Za-z]'), '');
                                          controller.inputController.text =
                                              '$output $data ';
                                          controller.input =
                                              controller.inputController.text;
                                          controller.inputController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: controller
                                                    .inputController
                                                    .text
                                                    .length),
                                          );
                                          controller.hints.value = null;
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 4.0),
                                          decoration: BoxDecoration(
                                              color: const Color(0xffb9e9fc)
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text(
                                            data,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            );
                          }),
                        );
                      }),
                      const SizedBox(height: 10),
                      Obx(() {
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 4.0),
                            decoration: BoxDecoration(border: Border.all()),
                            child: TextField(
                              maxLines: null,
                              controller: controller.inputController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: controller.generatedInput.value ??
                                    'Please type something to translate ',
                              ),
                              onChanged: (v) {
                                controller.generatedInput.value = null;
                                controller.output.value = null;
                                controller.input = v;
                                if (v.isNotEmpty &&
                                    controller
                                        .transliterationModelId.isNotEmpty) {
                                  controller.getTransliterationInput();
                                  if (!(v[v.length - 1]
                                          .contains(RegExp('[^A-Za-z]'))) &&
                                      (controller.sourceLang.isNotEmpty ??
                                          false)) {
                                    controller.computeTransliteration();
                                  }
                                }
                                if (v.isEmpty) {
                                  controller.hints.value = null;
                                }
                                controller.ttsFilePath = '';
                                controller.enableTranslateButton();
                                controller.enablePlayButton();
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      Obx(() {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 4.0),
                            child: TextField(
                              maxLines: null,
                              readOnly: true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: controller.output.value ??
                                      'Output will be here',
                                  hintStyle: const TextStyle(
                                      overflow: TextOverflow.visible)),
                              // maxLines: 5,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            return FilledButton(
                              onPressed: () {
                                (!controller.recordingOngoing.value)
                                    ? controller.startRecording()
                                    : controller.stopRecordingAndGetResult();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    controller.recordingOngoing.value
                                        ? ColorConst.red
                                        : ColorConst.deepGreen,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                              ),
                              child: Text(
                                controller.recordingOngoing.value
                                    ? 'Stop Recording'
                                    : 'Start Recording',
                              ),
                            );
                          }),
                          const SizedBox(width: 20),
                          Obx(() {
                            return FilledButton(
                              onPressed: () {
                                if ((controller.sourceLang.value?.isNotEmpty ??
                                        false) &&
                                    (controller.targetLang.value?.isNotEmpty ??
                                        false)) {
                                  controller.performComputation();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    controller.enableTranslate.value
                                        ? ColorConst.green
                                        : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 35),
                              ),
                              child: controller.computationLoader.value
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text('Translate'),
                            );
                          }),
                          const SizedBox(width: 20),
                          Obx(() {
                            return GestureDetector(
                              onTap: () {
                                if (controller.ttsFilePath.isNotEmpty) {
                                  controller.playRecordedAudio(
                                      controller.ttsFilePath);
                                } else {
                                  if (controller.output.value?.isNotEmpty ??
                                      false) {
                                    controller.computeTts();
                                  }
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: controller.ttsComputeLoader.value
                                    ? 40
                                    : null,
                                width: controller.ttsComputeLoader.value
                                    ? 40
                                    : null,
                                padding: controller.ttsComputeLoader.value
                                    ? const EdgeInsets.all(10)
                                    : null,
                                decoration: BoxDecoration(
                                    color:
                                        controller.enablePlayPauseButton.value
                                            ? ColorConst.deepGreen
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(25)),
                                child: controller.ttsComputeLoader.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      )
                                    : Obx(() {
                                        return Icon(
                                          controller.playTTs.value
                                              ? Icons
                                                  .pause_circle_outline_outlined
                                              : Icons.play_circle_outlined,
                                          color: ColorConst.white,
                                          size: 40,
                                        );
                                      }),
                              ),
                            );
                          })
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Time for ULCA config call is: ${controller.configApiCallTime}ms',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          );
                        },
                      ),
                      Obx(
                        () {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Time for Dhruva Api compute call is: ${controller.computeApiCallTime}ms',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
