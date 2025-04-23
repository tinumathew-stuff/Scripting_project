#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use List::Util qw(min max);
use Time::HiRes qw(gettimeofday tv_interval);

# Configuration - Now visible during execution
my $config = {
    MAX_ITERATIONS => 20,
    TARGET_SLACK   => 0.1,
    MIN_CLOCK      => 1.0,
    MAX_CLOCK      => 20.0,
    CLOCK_MARGIN   => 1.10, # 10% safety margin
};

# ANSI color codes for better visibility
my $colors = {
    reset  => "\033[0m",
    green  => "\033[32m",
    red    => "\033[31m",
    yellow => "\033[33m",
    cyan   => "\033[36m",
};

# Initialize with verbose mode
my $verbose = 1;

GetOptions(
    "file=s"   => \my $verilog_file,
    "clock=f"  => \my $clock_period,
    "power=f"  => \my $power_budget,
    "area=i"   => \my $area_budget,
    "quiet"    => sub { $verbose = 0 },
    "iter=i"   => \$config->{MAX_ITERATIONS},
    "slack=f"  => \$config->{TARGET_SLACK},
    "min=f"    => \$config->{MIN_CLOCK},
    "max=f"    => \$config->{MAX_CLOCK},
) or die "Usage: $0 --file <verilog> [--clock ns] [--power mW] [--area LUTs] [--iter] [--slack] [--min] [--max] [--quiet]\n";

# Live output with optional clearing
sub live_out {
    my ($msg, $clear_line) = @_;
    print "\r" . (" " x 80) . "\r" if $clear_line;
    print "$msg\n" unless ($msg =~ /^\s*$/);
}

# Print section headers with timing
sub section {
    my ($title) = @_;
    my $time = scalar localtime;
    live_out("\n$colors->{cyan}=== $title === $colors->{yellow}$time$colors->{reset}\n");
}

# --- Synthesis Engine ---
sub run_synthesis {
    my ($clock, $power, $area) = @_;
    my $start = [gettimeofday];
    
    # (Actual synthesis commands would go here)
    # Simulating synthesis results for this example:
    my %result = (
        timing_met => ($clock >= 5.0) ? 1 : 0, # Fake condition
        slack      => max(0, $clock - 5.0 + rand(0.2) - 0.1),
        power      => $power * (0.8 + rand(0.4)),
        area       => $area  * (0.7 + rand(0.6)),
    );
    
    # Calculate score (0-200 range)
    $result{score} = ($result{timing_met} ? 100 : 0)
                   + min(50, $result{slack} * 100)
                   + min(50, ($power - $result{power}) / $power * 100)
                   + min(50, ($area - $result{area}) / $area * 100);
    
    if ($verbose) {
        live_out(sprintf("  %sClock:%.2fns Power:%.1fmW Area:%d LUTs",
                  $result{timing_met} ? $colors->{green} : $colors->{red},
                  $clock, $power, $area));
        live_out(sprintf("  Results: Slack:%.2fns Power:%.1fmW Area:%d Score:%.1f/200",
                  $result{slack}, $result{power}, $result{area}, $result{score}));
        live_out(sprintf("  Runtime: %.2fs", tv_interval($start)));
    }
    
    return %result;
}

# --- Phase 1: Clock Optimization ---
sub optimize_clock {
    my ($power, $area) = @_;
    my ($low, $high) = ($config->{MIN_CLOCK}, $config->{MAX_CLOCK});
    my ($best_clock, %best) = ($high, (score => 0));
    
    section("CLOCK PERIOD OPTIMIZATION");
    live_out("Search Range: $low-$high ns | Target Slack: $config->{TARGET_SLACK}ns");
    
    for my $iter (1..$config->{MAX_ITERATIONS}) {
        my $mid = sprintf("%.2f", ($low + $high)/2);
        live_out(sprintf("%sIter%02d:%s Testing %s%.2fns%s (Range: %.2f-%.2f)",
                  $colors->{yellow}, $iter, $colors->{reset},
                  $colors->{cyan}, $mid, $colors->{reset}, $low, $high), 1);
        
        my %result = run_synthesis($mid, $power, $area);
        
        if ($result{timing_met}) {
            ($best_clock, %best) = ($mid, %result);
            $high = $mid;
            live_out("  $colors->{green}✓ Timing Met! (Slack: $result{slack}ns)$colors->{reset}");
        } else {
            $low = $mid;
            live_out("  $colors->{red}✗ Timing Failed (Slack: $result{slack}ns)$colors->{reset}");
        }
        
        last if ($high - $low) < $config->{TARGET_SLACK};
    }
    
    $best_clock *= $config->{CLOCK_MARGIN};
    live_out("\n$colors->{green}★ Best Clock: ${best_clock}ns (Slack: $best{slack}ns Score: $best{score}/200)$colors->{reset}");
    return ($best_clock, %best);
}

# --- Phase 2: Power/Area Optimization ---
sub optimize_power_area {
    my ($clock) = @_;
    my ($best_power, $best_area) = ($power_budget, $area_budget);
    my (%best, $best_score) = (score => 0);
    
    section("POWER/AREA OPTIMIZATION");
    my $total_steps = (($power_budget * 0.5 / ($power_budget * 0.1)) + 1) 
                    * (($area_budget * 0.5 / ($area_budget * 0.1)) + 1);
    my $current_step = 0;
    
    for (my $p = $power_budget; $p >= $power_budget*0.5; $p -= $power_budget*0.1) {
        for (my $a = $area_budget; $a >= $area_budget*0.5; $a -= $area_budget*0.1) {
            $current_step++;
            my $progress = int(100*$current_step/$total_steps);
            live_out(sprintf("[%3d%%] Testing P=%.1fmW A=%dLUTs", 
                      $progress, $p, $a), 1);
            
            my %result = run_synthesis($clock, $p, $a);
            
            if ($result{score} > $best_score) {
                ($best_power, $best_area) = ($p, $a);
                %best = %result;
                live_out("  $colors->{green}★ New Best! Score: $result{score}/200$colors->{reset}");
            }
        }
    }
    
    live_out("\n$colors->{green}★ Optimal Configuration:$colors->{reset}");
    live_out("  Clock: ${clock}ns | Power: ${best_power}mW | Area: ${best_area}LUTs");
    live_out("  Results: Slack=$best{slack}ns Power=$best{power}mW Area=$best{area} Score=$best{score}/200");
    return ($best_power, $best_area, %best);
}

# --- Main Execution ---
section("ADVANCED SYNTHESIS STARTED");
live_out("Design: $verilog_file");
live_out("Initial Constraints: Clock=$clock_period ns Power=$power_budget mW Area=$area_budget LUTs");

my ($final_clock, %clock_results) = optimize_clock($power_budget, $area_budget);
my ($final_power, $final_area, %final_results) = optimize_power_area($final_clock);

section("FINAL RESULTS");
live_out("$colors->{green}Optimized Constraints:$colors->{reset}");
live_out(sprintf("Clock Period: %.2f ns (%.2fns slack)", 
          $final_clock, $final_results{slack}));
live_out(sprintf("Power Budget: %.1f mW (%.1f mW used)", 
          $final_power, $final_results{power}));
live_out(sprintf("Area Budget: %d LUTs (%d LUTs used)", 
          $final_area, $final_results{area}));
live_out(sprintf("Final Score: %.1f/200", $final_results{score}));

# Generate machine-readable report
open(my $report, '>', 'optimization_report.txt');
print $report join("\t", qw(Clock Power Area Slack Score)), "\n";
print $report join("\t", $final_clock, $final_power, $final_area, 
                   $final_results{slack}, $final_results{score}), "\n";
close $report;

section("SYNTHESIS COMPLETE");
