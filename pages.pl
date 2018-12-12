#!/usr/bin/env perl
# Converts the regular pages linked from the main page to Markdown files.
use strict;
use warnings;
use 5.020;
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

my @urls = ( 'download', 'docs', 'usermin', 'virtualmin', 'cloudmin', 'community', 'mirrors', 'devel', 'intro', 'support', 'demo', 'lang', 'changes', 'about', 'security' );
my @html_urls = ( 'download', 'third', 'standard', 'updates' );
my @entries;
for my $url ( @urls ) {
  my $ua  = Mojo::UserAgent->new;
  my $res = $ua->get("webmin.com/$url.html");

  my $main = $res->res->dom->at('#main');
  my $md = $wc->html2wiki( $main );
  my $title = ucfirst($url);
  write_md($title, $md);
}
# Don't convert these to Markdown, because they have tables
for my $html_url ( @html_urls ) {
  my $ua = Mojo::UserAgent->new;
  my $res = $ua->get("webmin.com/$html_url.html");

  my $main = $res->res->dom->at('#main');
  my $title = $res->res->dom->find('#main > h1')->map('text')->first;
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

