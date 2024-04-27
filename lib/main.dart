import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import "package:http/http.dart" as http;
import 'package:url_launcher/link.dart';

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

class ShortenedLink {
  final String longLink;
  final String resultUrl;
  final DateTime createdAt = DateTime.now();

  ShortenedLink({required this.longLink, required this.resultUrl});

  factory ShortenedLink.fromJson(Map<String, dynamic> json, String longLink) {
    return switch (json) {
      {'result_url': String resultUrl} =>
        ShortenedLink(longLink: longLink, resultUrl: resultUrl),
      _ => throw const FormatException("Failed to shorten URL"),
    };
  }
}

class LinkForm extends StatefulWidget {
  const LinkForm({super.key});

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  var longLink = "";
  var isLoading = false;
  final shortenedLinks = <ShortenedLink>{};

  void shortenLink() async {
    try {
      setState(() {
        isLoading = true;
      });
      final shortenedLink = await fetchShortenedLink();
      setState(() {
        shortenedLinks.add(shortenedLink);
      });
    } catch (exception) {
      return;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<ShortenedLink> fetchShortenedLink() async {
    final response = await http
        .post(Uri.parse("https://cleanuri.com/api/v1/shorten"), body: {
      "url": longLink,
    });

    if (response.statusCode == 200) {
      return ShortenedLink.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>, longLink);
    } else {
      throw Exception("Failed to shorten URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          color: theme.colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    onChanged: (value) => setState(() {
                      longLink = value;
                    }),
                    decoration: const InputDecoration(
                      hintText: "Shorten a link here...",
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            shortenLink();
                          },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Shorten It!"),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
      Column(
        children: shortenedLinks
            .map((shortenedLink) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinkCard(shortenedLink: shortenedLink),
                ))
            .toList(),
      ),
    ]);
  }
}

class LinkCard extends StatelessWidget {
  final ShortenedLink shortenedLink;
  const LinkCard({
    super.key,
    required this.shortenedLink,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shortenedLink.longLink),
            const Divider(
              thickness: 2,
            ),
            const SizedBox(
              height: 16,
            ),
            Link(
                uri: Uri.parse(shortenedLink.resultUrl),
                builder: (context, followLink) => TextButton(
                      onPressed: followLink,
                      child: Text(
                        shortenedLink.resultUrl,
                        style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.primaryColor),
                      ),
                    )),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: () {}, child: const Text("Copy to clipboard"))
          ],
        ),
      ),
    );
  }
}
