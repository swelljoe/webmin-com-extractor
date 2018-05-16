#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use HTML::WikiConverter;
#my $html = "This release updates a bunch of script installers, adds security improvements to ensure that file operations on home directories are done with the correct permissions, adds a page for associating and disassociating features, makes the hash format for SSL certs selectable, and <a href=vchanges.html>more</a>.  You can get the GPL version from the <a href=vdownload.html>Virtualmin downloads page</a>, or from our YUM and APT repositories.";
my $html = "";
my $wc = new HTML::WikiConverter( dialect => 'Markdown' );
print $wc->html2wiki( $html );

