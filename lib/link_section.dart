import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_shortener/animated_status_container.dart';
import 'package:url_shortener/link_card.dart';
import 'package:url_shortener/link_form.dart';
import 'package:url_shortener/shortened_link.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

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
