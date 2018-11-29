#!/usr/bin/env perl
# Downloads and converts the news sections of main page and oldnews.html
# into individual markdown files for the news/ section in the Hugo site.
use strict;
use warnings;
use 5.020;
use Mojo::UserAgent;
use Time::Piece;
use String::Truncate qw(elide);
use HTML::WikiConverter;

use File::Path qw(make_path);
eval { make_path('content/news') };
if ($@) {
  say "Failed to create 'content/news' directory: $@";
  exit 1;
}

# Convert HTML to markdown
my $wc = new HTML::WikiConverter(dialect => 'Markdown');

my @entries;
for my $url ('webmin.com', 'webmin.com/oldnews.html') {
  my $ua  = Mojo::UserAgent->new;
  my $res = $ua->get($url);

  my $main    = $res->res->dom->at('#main');
  my @headers = $main->find('h3')->map('text')->each;
  my @hcols   = $main->find('h3')->each;
  my @paras;
  for my $h (@hcols) {
    push(@paras, $h->next->content);
  }
  my @dates = $main->find('.date')->map('text')->each;
  my $idx   = 0;
  for my $date (@dates) {
    # Munge funky data
    $date =~ s/Jul 18/July 18/;
    $date =~ s/Jun (\w)+/June $1/;

    # Get date into this format: 2017-09-30T20:42:08-05:00
    my $tp = Time::Piece->strptime($date, "%B %d, %Y");
    my $fixed = $tp->strftime("%Y-%m-%d");
    $paras[$idx] =~ s/^[\n]//;
    my $md;
    if ($paras[$idx]) {
      $md = $wc->html2wiki( $paras[$idx] );
    }
    else {
      $md = $paras[$idx];
    }
    push(@entries,
      {date => $fixed, title => $headers[$idx], text => $md});
    $idx++;
  }
}

for my $e (@entries) {
  my $desc = elide($e->{'text'}, 100, {at_space => 1});
  my $md = <<"EOF";
---
title: "$e->{'title'}"
date: $e->{'date'}
description: "$desc"
categories: []
aliases: []
toc: false
draft: false
---
$e->{'text'}
EOF

  my $filename = lc $e->{'title'}; 
  $filename =~ s/\s/-/g;
  $filename =~ s/[!,()'"\/]//g;
  open(my $FILE, ">", "content/news/$filename.md");
  print $FILE $md;
  close $FILE;
}

