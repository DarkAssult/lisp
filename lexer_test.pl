#!/usr/bin/perl 
use strict;
use warnings;

use LWP::Simple;
use JSON;
use lexer;
use parser;

my $html=get("https://api.github.com/gists/bf8ee516f5806355ed3a");
my $gist = decode_json $html;
my $files = $gist->{'files'};
my $i=1;
my %lexer_tests;

while ( my ($key, $file) = each(%$files) ) {
	if ($key =~ /^(parser-\d+).lisp/) {
		$lexer_tests{$file->{"content"}} = $files->{"$1.json"}{"content"};
		
		my $lisp_txt = "lexer-".$i.".lisp";
		my $answer_txt = "lexer-".$i.".json";
		
		open OUTFH, ">", $lisp_txt;
		print OUTFH $file->{"content"};
		close OUTFH;
		
		open OUTFH, ">", $answer_txt;
		print OUTFH $lexer_tests{$file->{"content"}};
		close OUTFH;
		
		lexer::main($lisp_txt,$i);
		parser::Lexer_to_Parser($i);
		$i++;
	}
}

