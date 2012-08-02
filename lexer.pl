#!/usr/bin/perl -w
use strict;

=for comment
  Commented text
=cut

sub read_text
{
	# This subroutine read from text file.
	# When we use this, we must send parameter, file name string value.
	# For example, file name string value shows below.
	# ==========================================
	# "<example1.txt"
	# "<example2.c"
	# "<example3.lisp"  
	#
	# We can use this for only text file format. 
	# However, you must type redirection mark (<) first in file name string value
	#
	# It returns this file's all lines.
	# I'll show you how can we use this subroutine.
	# ==========================================
	# my $filename = "<lexer-1.lisp";
	# my @lines=&read_text($filename);
	
	open FH,$_[0];
    my @temp_lines = <FH>;
 
    close(FH);
    
    return @temp_lines;
}

sub match_file {
	
	# This subroutine compare two files, then it returns 0 (match) or 1 (unmatch) value.
	# When unmatched, it print unmatched line.
	# It doesn't use parameter from caller.
	#
	# We can use this for only text file format.
	# However, you must type redirection mark (<) first in file name string value.
	# In this subroutine, compare_file_name and lexer_output_file_name variable contain file name string value.
	# (You can change variable name.)
	# For example, file name string value shows below.
	# ==============================================
	# "<example1.txt"
	# "<example2.c"
	# "<example3.lisp" 
	# 
	# I'll show you how can we use this subroutine.
	# ==============================================
	# my $test_result=&match_file;
	# print "pass" if $test_result == 0;
	# print "fail" if $test_result == 1;
	
	my $compare_file_name = "<lexer-1.txt";
	my $lexer_output_file_name = "<output.txt";
	my @compare_file=&read_text($compare_file_name);
	my @lexer_output_file=&read_text($lexer_output_file_name);
	my $ne_flag=0;
	my $index=0;
	
	foreach my $i (@compare_file){
		chomp ($i,$lexer_output_file[$index]);
		$ne_flag=1 if $i ne $lexer_output_file[$index];
		last if $ne_flag==1;
		$index++;
	}
	print $lexer_output_file[$index] if $ne_flag==1;
	return ($ne_flag);
}
sub extract_token_from_line {
	
	# This subroutine extract tokens from one line.
	# When it'll receive one string value line through parameter, it performs loop.
	# In this loop, it makes tokens by empty characters and then analyzes tokens.
	# If token was surrounded by '\"', this subroutine will measure it to STRING and call string_tokenizer subroutine.
	# If token was NUMBER or SYMBOL, this subroutine will call symbol_number_token subroutine.
	#
	# In this subroutine, it used parameters.
	# I'll show you how can we use this subroutine.
	# ==============================================
	#
	#	my @temp=split "", $i;  # $i variable must contain string value.
	#	my $index_token=0;		# index_token and last_duquote variable must contain integer value.
	#	my $last_doquote=0;
	#	
	#	&extract_token_from_line($index_token,$last_doquote,$i,@temp);
	# 
	#   # When we call extract_token_from_line, we must send in order above and take care of parameter's type. 
	
	
	my $temp_index=0;
	my $temp_token='';
	my($index_token,$last_doquote,$i,@temp)=@_;
    
	foreach my $character (@temp){
		if($character eq "\""){
			($index_token,$last_doquote)=&string_tokenizer($index_token,$last_doquote,$i,@temp);
			last;
		}
		elsif($character eq "("){
			print OUTFH "OPEN (\n";
			$temp_token=&symbol_number_token($temp_token);
		}
		elsif($character eq ")"){
			$temp_token=&symbol_number_token($temp_token);
			print OUTFH "CLOSE )\n";
		}
		elsif($character =~ /\s/){
			$temp_token=&symbol_number_token($temp_token);
			next;
		}
		else{ 
			$temp_token = $temp_token.$character if ($character ne '');
		}
	}
}

sub symbol_number_check {
	# This subroutine checks SYMBOL or NUMBER for input token.
	# We used regular expression for checking NUMBER token.
	# If token wasn't consist of number only, then this subroutine decide it was SYMBOL. 
	#
	# I'll show you how can we use this subroutine.
	# ==============================================
	# 
	#		symbol_number_check($token);
	
	my($token)=@_;
	
	if($token =~ /^[0-9]+$/){
		print OUTFH "NUMBER ".$token."\n";
	}
	else {
		print OUTFH "SYMBOL ".$token."\n";
	}
}

sub symbol_number_token {
	
	# This subroutine checks for input token was empty.
	# It tests whether token was empty or not empty.
	# If token was not empty, then it calls symbol_number_check for checks this token was SYMBOL or NUMBER.
	# 
	# It returns token with empty string value.
	# Because caller's token must initialize for saving next token.
	# (But if you don't make empty token in caller's token variable, you don't need to return token value.)
	# I'll show you how can we use this subroutine.
	# ==============================================
	#
	#	# When symbol_number_token calls over, $temp_token will be initialized by empty token.
	#	$temp_token=&symbol_number_token($temp_token);	
	 
	my($token)=@_;
	
	if($token ne ''){
		symbol_number_check($token);
	}
	$token='';
	return ($token);
}

sub string_tokenizer {
	# This subroutine checks STRING for input token.
	# In loop, it checks continuous double quote('"').
	# However, if double quote appeared after '\', it means double quote character in string.
	# In this case, we don't quit string value and find next double quote not appeared after '\'.
	# When we find string token, we save last double quote index in line and token.
	# Because, if we find two string token in one line, we print two STRING and string token.
	# This subroutine returns above infomaiton.
	#
	# I'll show you how can we use this subroutine.
	# ==============================================
	#
	# ($index_token,$last_doquote)=&string_tokenizer($index_token,$last_doquote,$i,@temp);	
	
	my($index_token,$last_doquote,$i,@temp)=@_;
	my $string_token=undef;
	my $string_last_doquote=rindex($i,"\"");
	
	if($string_last_doquote > $last_doquote){
		if($index_token == $last_doquote){
			$index_token = index($i,"\"");
			$last_doquote++;
			while (1){
				$string_token = $string_token.$temp[$index_token];
				$index_token++;
				if($temp[$index_token] eq "\""){
					$last_doquote++;
					last if ($temp[$index_token-1] ne "\\");
				}
			}
			$string_token = $string_token.$temp[$index_token];
			print OUTFH "STRING ".$string_token."\n";
			$index_token=0;
			$string_token=undef;
		}
	}
	return ($index_token,$last_doquote);
}

sub tokenizer {
	# This subroutine performs tokenizing input file lines one by one.
	# In loop, one input file line will be tokenized each single characters and then call 
	# extract_token_from_line subroutine in order to tokenize input file's lines.
	#
	# Therefore, this subroutine need to array type parameter consists of string values.
	# I'll show you how can we use this subroutine.
	# ==============================================
	#
	# my @lines= ... ;     # @lines must contain string value array.
 	# &tokenizer(@lines);
	
	foreach my $i (@_){
		chomp($i);
		my @temp=split "", $i;
		my $index_token=0;
		my $last_doquote=0;
		
		&extract_token_from_line($index_token,$last_doquote,$i,@temp);
	}
}

sub lexer {
	
	# This subroutine performs tokenizing input file.
	# In order to tokenize input file, it calls read_text subroutine.
	#
	# We can edit input file name in this subroutine.
	# However, you must type redirection mark (<) first in file name string value.
	# In this subroutine, filename variable contain file name string value.
	# (You can change variable name.)
	# For example, file name string value shows below.
	# ==============================================
	# "<example1.txt"
	# "<example2.c"
	# "<example3.lisp" 
	# 
	# I'll show you how can we use this subroutine.
	# ==============================================
	# &lexer;
	#
	
	my $filename = "<lexer-1.lisp";
	my @lines=&read_text($filename);
 	&tokenizer(@lines);
}

sub main{
	
	# This subroutine is main subroutine.
	# It starts lexer program and then returns result of match_file subroutine.
	# If lexer's output file we made and answer file will be matched, it'll print "pass".
	# If not, it'll print "fail".
	#
	# In this subroutine, we can edit output file name.
	# (Output file handler will be used in lexer subroutine.)
	# We can change file handler name.
	# (In this case, we use OUTFH file handler.)
	#
	# I'll show you how can we use this subroutine.
	# ==============================================
	# &main;
	#
	
	open OUTFH, ">", "output.txt";
	&lexer;
	close OUTFH;
	my $test_result=&match_file;
	print "pass" if $test_result == 0;
	print "fail" if $test_result == 1;	
}

&main;