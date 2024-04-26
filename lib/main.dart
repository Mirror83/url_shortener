import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Shortly'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(1, 1, 1, 1),
        title: Text(title),
      ),
      drawer: Drawer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('This is the Drawer'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close Drawer'),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: const <Widget>[LinkForm()],
      ),
    );
  }
}

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

class LinkForm extends StatefulWidget {
  const LinkForm({super.key});

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Shorten a link here...",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Shorten It!"),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
