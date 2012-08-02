#!/usr/bin/perl -w
use strict;
use warnings;

use LWP::Simple;
use JSON::PP;
use lexer;

my $html=get("https://api.github.com/gists/bf8ee516f5806355ed3a");
my $gist = decode_json $html;
my $files = $gist->{'files'};
my $i=1;
my %lexer_tests;

while ( my ($key, $file) = each(%$files) ) {
	if ($key =~ /^(lexer-\d+).lisp/) {
		$lexer_tests{$file->{"content"}} = $files->{"$1.txt"}{"content"};
		open OUTFH, ">", "lexer-".$i.".lisp";
		print OUTFH $file->{"content"};
		close OUTFH;
		
		open OUTFH, ">", "lexer-".$i.".txt";
		print OUTFH $lexer_tests{$file->{"content"}};
		close OUTFH;
		lexer::main;
		$i++;
	}
}

