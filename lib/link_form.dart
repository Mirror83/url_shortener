import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_shortener/shortened_link.dart';

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
