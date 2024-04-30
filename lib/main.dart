import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  /// Arbitrary minimum length for a URL
  static const minUrlLength = 30;

  final String? Function(String?) linkFieldValidator;
  final Future<ShortenedLink>? shortenedLinkFuture;
  final void Function(String) shortenLink;

  const LinkForm({
    super.key,
    required this.linkFieldValidator,
    required this.shortenedLinkFuture,
    required this.shortenLink,
  });

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  var longLink = "";

  final _formKey = GlobalKey<FormState>();

  void updateLongLink(String value) {
    setState(() {
      longLink = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    validator: widget.linkFieldValidator,
                    decoration: const InputDecoration(
                      hintText: "Shorten a link here...",
                    ),
                    onChanged: (value) {
                      if (_formKey.currentState!.validate()) {
                        updateLongLink(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder(
                      future: widget.shortenedLinkFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.shortenLink(longLink);
                            }
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Shorten It!"),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ]),
        ),
      ),
    );
  }
}

class LinkSection extends StatefulWidget {
  const LinkSection({super.key});

  @override
  State<LinkSection> createState() => _LinkSectionState();
}

class _LinkSectionState extends State<LinkSection> {
  Future<ShortenedLink>? shortenedLinkFuture;
  Future<ClipboardData?>? latestLinkOnClipboardFuture;

  final shortenedLinks = <ShortenedLink>{};

  String? linkFieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please add a link";
    } else if (value.length < LinkForm.minUrlLength) {
      return "Url must be at least ${LinkForm.minUrlLength}characters long";
    } else if (Uri.tryParse(value) == null) {
      return "Ensure that the link is well-formatted";
    } else if (shortenedLinks.any((element) => element.longLink == value)) {
      return "Link has already been shortened";
    }

    return null;
  }

  void shortenLinkWithFuture(String value) {
    setState(() {
      shortenedLinkFuture = fetchShortenedLink(value).then((value) {
        setState(() {
          shortenedLinks.add(value);
        });
        return value;
      });
    });
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
      throw "Failed to shorten URL. Ensure that the link is valid";
    }
  }

  void getLatestLinkOnClipboard() {
    setState(() {
      latestLinkOnClipboardFuture = Clipboard.getData("text/plain");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinkForm(
          linkFieldValidator: linkFieldValidator,
          shortenLink: shortenLinkWithFuture,
          shortenedLinkFuture: shortenedLinkFuture,
        ),
        buildStatusContaier(context),
        Column(
          children: shortenedLinks
              .map((shortenedLink) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LinkCard(
                      latestLinkOnClipboardFuture: latestLinkOnClipboardFuture,
                      getLatestLinkOnClipboard: getLatestLinkOnClipboard,
                      shortenedLink: shortenedLink,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildStatusContaier(BuildContext context) {
    return FutureBuilder(
        future: shortenedLinkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return AnimatedStatusContainer(
                message: snapshot.error!.toString(),
                isError: true,
              );
            } else if (snapshot.hasData) {
              return const AnimatedStatusContainer(message: "Link shortened!");
            }
          }

          return const SizedBox.shrink();
        });
  }
}

class LinkCard extends StatefulWidget {
  final ShortenedLink shortenedLink;
  final Future<ClipboardData?>? latestLinkOnClipboardFuture;
  final void Function() getLatestLinkOnClipboard;

  const LinkCard({
    super.key,
    required this.shortenedLink,
    this.latestLinkOnClipboardFuture,
    required this.getLatestLinkOnClipboard,
  });

  @override
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
  Future<void>? copiedToClipBoardFuture;

  void addToClipboard() {
    setState(() {
      copiedToClipBoardFuture =
          Clipboard.setData(ClipboardData(text: widget.shortenedLink.resultUrl))
              .then((value) {
        setState(() {
          widget.getLatestLinkOnClipboard();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shortenedLink.longLink),
            const Divider(
              thickness: 2,
            ),
            const SizedBox(
              height: 16,
            ),
            Link(
                uri: Uri.parse(widget.shortenedLink.resultUrl),
                builder: (context, followLink) => TextButton(
                      onPressed: followLink,
                      child: Text(
                        widget.shortenedLink.resultUrl,
                        style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.primaryColor),
                      ),
                    )),
            const SizedBox(height: 16),
            FutureBuilder(
                future: copiedToClipBoardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return OutlinedButton(
                          onPressed: addToClipboard,
                          child: const Text(
                              "Failed to copy to clipboard. Press to try again."));
                    } else {
                      return FutureBuilder(
                        future: widget.latestLinkOnClipboardFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              return OutlinedButton(
                                  onPressed: addToClipboard,
                                  child: const Text(
                                      "Failed to copy to clipboard. Press to try again."));
                            }

                            if (snapshot.hasData) {
                              developer.log(snapshot.data!.text.toString());
                              if (snapshot.data!.text !=
                                  widget.shortenedLink.resultUrl) {
                                return OutlinedButton(
                                    onPressed: addToClipboard,
                                    child: const Text("Copy to clipboard"));
                              }
                            }
                          }

                          return const OutlinedButton(
                              onPressed: null,
                              child: Text("Successfully copied"));
                        },
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return OutlinedButton(
                        onPressed: addToClipboard,
                        child: const Text("Copy to clipboard"));
                  }
                })
          ],
        ),
      ),
    );
  }
}

class AnimatedStatusContainer extends StatefulWidget {
  final String message;
  final bool isError;

  const AnimatedStatusContainer(
      {super.key, this.isError = false, required this.message});

  @override
  State<AnimatedStatusContainer> createState() =>
      _AnimatedStatusContainerState();
}

/// A container that shows a message for a short period of time and then shrinks
class _AnimatedStatusContainerState extends State<AnimatedStatusContainer> {
  double _width = 0;
  double _height = 0;
  bool isExpanded = false;

  /// The number of seconds for which the container is expanded
  final expandedSeconds = 5;

  /// The number of milliseconds for the transition between expanded and shrunken states
  final transitionMillis = 600;

  // Created expandedTimer as a class field to be able to cancel it when the widget is disposed
  late Timer expandedTimer;

  @override
  void dispose() {
    super.dispose();
    expandedTimer.cancel();
  }

  void shrink() {
    setState(() {
      isExpanded = false;
      _width = 0;
      _height = 0;
    });
  }

  void expand() {
    setState(() {
      // Arbitrary values
      _width = 300;
      _height = 30;
      isExpanded = true;
    });

    expandedTimer = Timer(Duration(seconds: expandedSeconds), shrink);
  }

  @override
  void initState() {
    super.initState();
    expand();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
        duration: Duration(milliseconds: transitionMillis),
        width: _width,
        height: _height,
        child: Text(
          widget.message,
          style: theme.textTheme.bodySmall!.copyWith(
              color: widget.isError
                  ? theme.colorScheme.error
                  : theme.primaryColor),
        ));
  }
}
