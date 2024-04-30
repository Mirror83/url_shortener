import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SvgPicture.asset(
          "assets/images/illustration-working.svg",
          semanticsLabel: null,
        ),
        Text(
          "More than just shorter links",
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const Text(
            "Build your brand's recognition and get detailed insights on how your links are performing."),
        ElevatedButton(onPressed: () {}, child: const Text("Get Started")),
      ],
    );
  }
}
