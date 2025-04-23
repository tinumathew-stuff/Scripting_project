#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $verilog_file;
GetOptions("file=s" => \$verilog_file) or die "Usage: $0 --file <verilog_file>\n";
die "Error: No Verilog file specified!\n" unless $verilog_file;

die "Error: File '$verilog_file' not found!\n" unless -e $verilog_file;

my $log_file = "report.log";

print "Synthesizing $verilog_file with Yosys...\n";
my $yosys_cmd = "yosys -p \"read_verilog -DSYNTHESIS \\\"$verilog_file\\\"; synth -top counter; show\" > $log_file 2>&1";
my $yosys_output = `$yosys_cmd`;

if ($? != 0) {
    die "Synthesis failed!\n";
}

print "Synthesis complete. Results saved in $log_file\n";
