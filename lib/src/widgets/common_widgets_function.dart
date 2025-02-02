import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget getRowWidgetForDetailsBox(String column1, String? column2,
    {Widget? optionalWidgetsAtLast}) {
  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Text(
            column1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const Text(
        ':  ',
        style: TextStyle(fontSize: 18),
      ),
      Expanded(
        flex: 4,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: optionalWidgetsAtLast != null
              ? Row(
                  children: [
                    Text(
                      column2 ?? '',
                      style: topContainerTextStyleForDetailsBox,
                    ),
                    const Gap(20),
                    optionalWidgetsAtLast
                  ],
                )
              : Text(
                  column2 ?? '',
                  style: topContainerTextStyleForDetailsBox,
                ),
        ),
      ),
    ],
  );
}

TextStyle topContainerTextStyleForDetailsBox = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
