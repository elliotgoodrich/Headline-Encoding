#!/bin/perl

use strict;
use warnings;

my @formats = ("noun");

# Output file
open JSFILE, ">headline.js";

print JSFILE <<EOL;
function headlineEncode(hex, format)
{
	hex = hex.toLowerCase();
	var output_format = format.split(' ');

	var lookup = {};
	for (var i = 0; i < 16; ++i) {
		lookup[i.toString(16)] = i.toString();
	}

	var words = {
EOL

# Open each CSV file of words
foreach my $file (@formats)
{
	open FILE, "<$file.csv" or die "Failed opening $file.csv! $!\n";
	my $line_number = 0;

	print JSFILE "\t\t\"$file\": [\n";

	while (<FILE>)
	{
		# Ignore the first two lines
		++$line_number;
		next if $line_number < 3;

		# Create a 2-dimensional array in the Javascript
		print JSFILE "\t\t\t[";

		my @lines = split(',', $_);
		for my $i (2 .. @lines-1) # Ignore the first two columns
		{
			chomp($lines[$i]);
			print JSFILE '"'.$lines[$i].'"';
			print JSFILE ',' if ($i < @lines - 1);
		}
		print JSFILE "],\n";
	}
	print JSFILE "\t\t],\n";
	close FILE;
}
print JSFILE "\t};\n";

print JSFILE <<EOL;
	for (var i = 0; i < output_format.length; ++i) {
		if (!(output_format[i] in words)) {
			return "";
		}
	}	

	var count = 0;
	var first_digit = '', second_digit = '';
	var output = "";

	for (var i = 0; i < Math.min(hex.length, 2*output_format.length); ++i) {
		var digit = hex.charAt(i);
		if (digit in lookup) {
			if (count == 0) {
				first_digit = lookup[digit];
				++count;
			} else {
				second_digit = lookup[digit];
				word_class = output_format[Math.floor(i/2)];
				output = output + " " + words[word_class][first_digit][second_digit];
				count = 0;
			}
		}
		else return "";
	}

	if (count == 1) {
		word_class = output_format[Math.floor(i/2)];
		output = output + " " + words[word_class][first_digit][16];
	}

	return output.trim();
}

function headlineDecode(sentence)
{
	sentence = sentence.toLowerCase();
EOL

# Open up an CSV file to get the character conversions
open CSV, "<$formats[0].csv";
my @numbers = split(',', <CSV>);
my @letters = split(',', <CSV>);
close CSV;

# Create a hex to character lookup
print JSFILE "\tvar lookup = {";
for my $i (0 .. @numbers-1) {
	chomp($letters[$i]);
	chomp($numbers[$i]);
	print JSFILE "\"$letters[$i]\":\"$numbers[$i]\", " if ($letters[$i]);
}
print JSFILE "};\n";

print JSFILE <<EOL;
	var count = 0;
	var output = "";
	var character = '';

	for (var i = 0; i < sentence.length; ++i) {
		character = sentence.charAt(i);
		if (character == ' ') {
			count = 0;
		} else if (count < 2 && character in lookup) {
			++count;
			output = output + lookup[character];
		}
	}

	return output;
}
EOL

close JSFILE;
