import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:delivery/src/widgets/loading/loading_text_controller.dart';

void showCustomPopUpLoadingDialog(BuildContext context,
    {bool isCupertino = true}) {
  // 0 -> loading
  // 1 -> success
  // -1 -> Error
  final Widget widget = Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: GetX<LoadingTextController>(
        builder: (controller) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.currentState.value != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            if (controller.currentState.value == 0)
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                  ),
                ],
              ),
            if (controller.currentState.value == 0)
              LoadingAnimationWidget.discreteCircle(
                color: Colors.blue.shade800,
                size: 50,
              ),
            if (controller.currentState.value == 1)
              Container(
                margin: const EdgeInsets.all(10),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100,
                  ),
                  color: Colors.green,
                ),
                child: const Icon(
                  Icons.done,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            if (controller.currentState.value == -1)
              Container(
                margin: const EdgeInsets.all(10),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100,
                  ),
                  color: Colors.red,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            const Gap(20),
            Text(
              controller.loadingText.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    ),
  );

  isCupertino == true
      ? showCupertinoDialog(
          context: context,
          builder: (context) => PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.grey.withOpacity(0.3),
              body: Center(
                child: widget,
              ),
            ),
          ),
        )
      : showDialog(
          context: context,
          builder: (context) {
            return widget;
          },
        );
}
