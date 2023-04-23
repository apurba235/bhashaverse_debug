import 'package:flutter/material.dart';

class SourceTargetLanguageButton extends StatelessWidget {
  const SourceTargetLanguageButton({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(title),
      ),
    );
  }
}
