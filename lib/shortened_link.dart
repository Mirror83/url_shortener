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
