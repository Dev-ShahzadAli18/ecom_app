import 'package:flutter/material.dart';

class CustomPageIndicator extends StatelessWidget {
  final int? currentIndex;
  final int totalPages;
  final String? itemcount;

  CustomPageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.itemcount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        bool active = index == currentIndex;

        return AnimatedContainer(
          duration: Duration(milliseconds: 250),

          margin: EdgeInsets.symmetric(horizontal: 4),

          height: 7,

          width: active ? 25 : 7,

          decoration: BoxDecoration(
            color: active ? Color(0xffF5B700) : Color(0xffD6D6D6),

            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
