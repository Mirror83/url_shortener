import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/link.dart';
import 'package:url_shortener/shortened_link.dart';
import 'dart:developer' as developer;

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
