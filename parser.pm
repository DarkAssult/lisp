#!/usr/bin/perl 

package parser;

use JSON;
use strict;
use warnings;
use Getopt::Long;

my $open_parenthesis = {
	success =>JSON::false(),
	error=>'unmatched-open'
};

my $close_parenthesis = {
	success =>JSON::false(),
	error=>'unmatched-close'
};

my $true_parenthesis = {
	success =>JSON::true(),	
	froms =>[{
		type => 'list',
		list => [{type=>'symbol',symbol=>'define'},{type=>'list'} ],
	}]
	
};

sub Json_Error_file_Handler {
	my ($i,$error_file_stream) = @_;
	open Parser_output,">","parser_output-".$i.".txt";
	print Parser_output $error_file_stream;
	print $error_file_stream."\n==\n";
}

sub read_from {
        my (@tokens) = @_;
        
        my $token = shift @tokens;
        if($token eq "("){
        	print $token;
        	my @L;
        	#while($token ne ")"){
        		
        	#	push @L,read_from(@tokens);
        	#}
        	shift @tokens;
        	print @L;
        	return \@L;
        }
        else{
        	print $token;
        	return $token;
        }
}

sub Collect_file_parser {
	my (@lexer_output_lines) = @_;
	my (%dict,@result_tokens,$one_line);
	
	foreach my $each_line_in_lexer_output (@lexer_output_lines){
		chomp($each_line_in_lexer_output);
		my @tokens = split /\s+/, $each_line_in_lexer_output;
		push @result_tokens, $tokens[1];
		$dict{$tokens[1]}=$tokens[0];
	}
	
	my @temp=read_from(@result_tokens);

}

sub Check_Parenthesis_Error {
	my($i,@stack_for_parenthesis)=@_;
	my $Parenthesis_flag = 0;
	
	if(@stack_for_parenthesis){
		my $parenthesis_type = shift @stack_for_parenthesis;
		my $error_json_file_stream;
		$Parenthesis_flag = 1;
		
		if($parenthesis_type eq '('){
			$error_json_file_stream = JSON->new->utf8->space_after->encode($open_parenthesis);	
		}
		else{
			$error_json_file_stream = JSON->new->utf8->space_after->encode($close_parenthesis);
		}
		#print "\n".JSON->new->utf8->space_after->encode($true_parenthesis)."\n";
		Json_Error_file_Handler($i,$error_json_file_stream);
	}
	
	return ($Parenthesis_flag);
}

sub Check_Parenthesis {
	my($i,@Lexer_lines)=@_;
	my @stack_for_parenthesis=( );

	foreach my $save_parenthesis (@Lexer_lines)
	{
		push @stack_for_parenthesis,'(' if($save_parenthesis =~ /\(/);	
		if($save_parenthesis =~ /\)/){
			unless(@stack_for_parenthesis){
				push @stack_for_parenthesis,')';
			}
			else{
				pop @stack_for_parenthesis;
			}
		}
	}
	
	Check_Parenthesis_Error($i,@stack_for_parenthesis);
	
}

sub Read_Lexer_Output {
	my($i,$lexer_output_filename) = @_;
	open Lexer_output_handler,"<",$lexer_output_filename;
	my @temp_lines = <Lexer_output_handler>;
 
    close(Lexer_output_handler);
    
    return @temp_lines;
}

sub Lexer_to_Parser{
	my($i) = @_;
	my $lexer_output_filename = "lexer_output-".$i.".txt";
	my @Lexer_output_array=Read_Lexer_Output($i,$lexer_output_filename);
	my $error_file_flag=Check_Parenthesis($i,@Lexer_output_array);
	
	Collect_file_parser(@Lexer_output_array) if($error_file_flag == 0);
	
}

