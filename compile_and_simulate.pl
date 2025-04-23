#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $verilog_file;
GetOptions("file=s" => \$verilog_file) or die "Usage: $0 --file <verilog_file>\n";
die "Error: No Verilog file specified!\n" unless $verilog_file;

die "Error: File '$verilog_file' not found!\n" unless -e $verilog_file;

my $output_file = "simulation.vvp";
my $log_file = "report.log";

print "Compiling $verilog_file...\n";
my $compile_cmd = "iverilog -o $output_file \"$verilog_file\" 2>&1";
my $compile_output = `$compile_cmd`;
if ($? != 0) {
    die "Compilation failed:\n$compile_output\n";
}
print "Compilation successful!\n";

print "Running simulation...\n";
my $simulate_cmd = "vvp $output_file > $log_file 2>&1";
my $simulate_output = `$simulate_cmd`;
if ($? != 0) {
    die "Simulation failed!\n";
}

print "Simulation complete. Results saved in $log_file\n";
