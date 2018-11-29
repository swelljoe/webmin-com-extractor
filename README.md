# webmin-com-extractor
Some scripts to convert Webmin.com website to Markdown for Hugo static site generator

Requires the following modules from CPAN:

  - Mojo::UserAgent for downloading and parsing the pages
  - Time::Piece for munging inconsistent dates into a format Hugo likes
  - String::Truncate qw(elide) for summarizing news items
  - HTML::WikiConverter for converting to Markdown
