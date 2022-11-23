#!/usr/bin/env perl
# Converts the regular pages linked from the main page to Markdown files.
use strict;
use warnings;
use 5.020;
use utf8::all;
use Mojo::UserAgent;
use Time::Piece;
use HTML::WikiConverter;
use List::Util qw(first);

use File::Path qw(make_path);
eval { make_path('content') };
if ($@) {
  say "Failed to create 'content' directory: $@";
  exit 1;
}

# Convert HTML to markdown
my $wc = new HTML::WikiConverter(dialect => 'Markdown');

my @urls = ( 'docs', 'usermin', 'virtualmin', 'cloudmin', 'community', 'mirrors', 'devel', 'intro', 'support', 'demo', 'changes', 'about', );
#my @urls = ( 'security' );
my @html_urls = ( 'lang', 'download', 'third', 'standard', 'updates' );
my @entries;
for my $url ( @urls ) {
  my $ua  = Mojo::UserAgent->new;
  my $tx = $ua->get("https://webmin.com/$url.html");
  say "$url";

  my $main = $tx->res->dom->at('#main');
  no warnings 'utf8';
  my $md = $wc->html2wiki( $main );
  my $title = ucfirst($url);
  write_md($title, $md);
}
# Don't convert these to Markdown, because they have tables
for my $html_url ( @html_urls ) {
  my $ua = Mojo::UserAgent->new;
  my $tx = $ua->get("https://webmin.com/$html_url.html");
  say "$url";

  my $main = $tx->res->dom->at('#main');
  my $title = $tx->res->dom->find('#main > h1')->map('text')->first;
  # Kill the title, since it'll be added by Hugo
  $main =~ s/<h1>${title}<\/h1>//;
  write_html($html_url, $title, $main);
}

sub write_md {
  my ($title, $md) = @_;
  my $date = '2017-10-02';
  my $out = <<"EOF";
---
title: "$title"
date: $date
categories: []
aliases: []
toc: false
draft: false
---
$md
EOF

  my $filename = lc $title; 
  $filename =~ s/\s/-/g;
  $filename =~ s/[!,()'"\/]//g;
  open(my $FILE, ">", "content/$filename.md");
  print $FILE $out;
  close $FILE;
}

sub write_html {
  my ($filename, $title, $html) = @_;
  my $date = '2017-10-02';
  my $out = <<"EOF";
---
title: "$title"
date: $date
categories: []
aliases: []
toc: false
draft: false
---
$html
EOF

  $filename =~ s/\s/-/g;
  $filename =~ s/[!,()'"\/]//g;
  open(my $FILE, ">", "content/$filename.md");
  print $FILE $out;
  close $FILE;
}

