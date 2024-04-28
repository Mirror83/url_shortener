import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import "package:http/http.dart" as http;
import 'package:url_launcher/link.dart';
import "dart:developer" as developer;

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
        children: const <Widget>[LinkSection()],
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

class LinkSection extends StatefulWidget {
  const LinkSection({super.key});

  @override
  State<LinkSection> createState() => _LinkSectionState();
}

class _LinkSectionState extends State<LinkSection> {
  // Arbitrarily decided minimum url length
  static const minUrlLength = 30;

  String longLink = "";
  var isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final shortenedLinks = <ShortenedLink>{};

  String? linkFieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please add a link";
    } else if (value.length < minUrlLength) {
      return "Url must be at least $minUrlLength characters long";
    } else if (Uri.tryParse(value) == null) {
      return "Ensure that the link is well-formatted";
    }

    updateLongLink(value);

    return null;
  }

  void updateLongLink(String value) {
    setState(() {
      longLink = value;
    });
  }

  void shortenLink(String longLink) async {
    try {
      setState(() {
        isLoading = true;
      });
      final shortenedLink = await fetchShortenedLink(longLink);
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

  Future<ShortenedLink> fetchShortenedLink(String longLink) async {
    final response = await http
        .post(Uri.parse("https://cleanuri.com/api/v1/shorten"), body: {
      "url": longLink,
    });

    developer.log("Long link: $longLink");
    developer.log(response.body);

    if (response.statusCode == 200) {
      return ShortenedLink.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>, longLink);
    } else {
      throw Exception("Failed to shorten URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        createLinkForm(context),
        Column(
          children: shortenedLinks
              .map((shortenedLink) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LinkCard(shortenedLink: shortenedLink),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget createLinkForm(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    validator: linkFieldValidator,
                    decoration: const InputDecoration(
                      hintText: "Shorten a link here...",
                    ),
                    onChanged: (value) {
                      _formKey.currentState!.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              shortenLink(longLink);
                            }
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
            ),
          ]),
        ),
      ),
    );
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
