#!/usr/bin/wish

wm title . "Advanced Verilog Design Flow GUI"
wm geometry . 800x600

label .lbl_title -text "Advanced Verilog Design Flow" -font {Helvetica 16 bold}
pack .lbl_title -pady 10

# File selection frame
frame .file_frame
pack .file_frame -side top -fill x -pady 5
label .file_frame.lbl_file -text "Verilog File:" 
entry .file_frame.entry_file -width 50 -textvariable verilog_file
set verilog_file "/home/tinumathew/sample.v"
button .file_frame.btn_browse -text "Browse" -command {
    set file [tk_getOpenFile -filetypes {{"Verilog Files" {.v}} {"All Files" {*}}}]
    if {$file != ""} {
        set verilog_file [file normalize $file]
    }
}
pack .file_frame.lbl_file .file_frame.entry_file .file_frame.btn_browse -side left -padx 5

# Constraints frame
frame .constraints_frame
pack .constraints_frame -side top -fill x -pady 5

label .constraints_frame.lbl_clock -text "Clock Period (ns):"
entry .constraints_frame.entry_clock -width 8 -textvariable clock_period
set clock_period 10

label .constraints_frame.lbl_power -text "Power Budget (mW):"
entry .constraints_frame.entry_power -width 8 -textvariable power_budget
set power_budget 100

label .constraints_frame.lbl_area -text "Area Budget (LUTs):"
entry .constraints_frame.entry_area -width 8 -textvariable area_budget
set area_budget 1000

pack .constraints_frame.lbl_clock .constraints_frame.entry_clock \
     .constraints_frame.lbl_power .constraints_frame.entry_power \
     .constraints_frame.lbl_area .constraints_frame.entry_area -side left -padx 5

# Advanced synthesis parameters frame
frame .adv_params_frame
pack .adv_params_frame -side top -fill x -pady 5

label .adv_params_frame.lbl_iter -text "Max Iterations:"
entry .adv_params_frame.entry_iter -width 5 -textvariable max_iterations
set max_iterations 20

label .adv_params_frame.lbl_target -text "Target Slack (ns):"
entry .adv_params_frame.entry_target -width 5 -textvariable target_slack
set target_slack 0.1

label .adv_params_frame.lbl_min -text "Min Clock (ns):"
entry .adv_params_frame.entry_min -width 5 -textvariable min_clock
set min_clock 1.0

label .adv_params_frame.lbl_max -text "Max Clock (ns):"
entry .adv_params_frame.entry_max -width 5 -textvariable max_clock
set max_clock 20.0

pack .adv_params_frame.lbl_iter .adv_params_frame.entry_iter \
     .adv_params_frame.lbl_target .adv_params_frame.entry_target \
     .adv_params_frame.lbl_min .adv_params_frame.entry_min \
     .adv_params_frame.lbl_max .adv_params_frame.entry_max -side left -padx 5

# Results frame
frame .results_frame
pack .results_frame -side top -fill x -pady 5

label .results_frame.lbl_best -text "Best Configuration:" -font {Helvetica 10 bold}
label .results_frame.lbl_best_config -textvariable best_config -justify left -anchor w
set best_config "Not run yet"

pack .results_frame.lbl_best .results_frame.lbl_best_config -side left -padx 5

# Output frame
frame .output_frame
pack .output_frame -side top -fill both -expand 1 -pady 5

text .output_frame.output_text -width 90 -height 20 -wrap word -yscrollcommand {.output_frame.scroll set}
scrollbar .output_frame.scroll -command {.output_frame.output_text yview}
pack .output_frame.scroll -side right -fill y
pack .output_frame.output_text -side left -fill both -expand 1

# Button frame
frame .button_frame
pack .button_frame -side bottom -fill x -pady 10

button .button_frame.btn_compile -text "Compile & Simulate" -command { run_perl_script "compile_and_simulate.pl" "Simulation" }
button .button_frame.btn_synthesize -text "Basic Synthesize" -command { run_perl_script "synthesize.pl" "Synthesis" }
button .button_frame.btn_adv_synth -text "Advanced Synthesize" -command { run_advanced_synthesis }
button .button_frame.btn_waveform -text "View Waveforms" -command { open_gtkwave }
button .button_frame.btn_report -text "Show Report" -command { show_report }
button .button_frame.btn_exit -text "Exit" -command { exit }

pack .button_frame.btn_compile .button_frame.btn_synthesize .button_frame.btn_adv_synth \
     .button_frame.btn_waveform .button_frame.btn_report .button_frame.btn_exit -side left -expand 1 -padx 5 -pady 5

# Procedures
proc run_perl_script {script action} {
    global verilog_file
    set filepath "\"$verilog_file\""

    if {$verilog_file == ""} {
        .output_frame.output_text insert end "\n\[ERROR\] No Verilog file selected!\n"
        .output_frame.output_text see end
        return
    }

    if {![file exists $script]} {
        .output_frame.output_text insert end "\n\[ERROR\] Script $script not found!\n"
        .output_frame.output_text see end
        return
    }

    set command "perl $script --file $filepath"
    puts "Executing: $command"

    if {[catch {exec sh -c $command} output]} {
        .output_frame.output_text insert end "\n\[ERROR\] Failed to execute $script:\n$output\n"
    } else {
        .output_frame.output_text insert end "\n\[$action Output\]\n$output\n"
    }
    .output_frame.output_text see end
}

proc run_advanced_synthesis {} {
    global verilog_file clock_period power_budget area_budget
    global max_iterations target_slack min_clock max_clock
    global best_config
    
    if {$verilog_file == ""} {
        .output_frame.output_text insert end "\n\[ERROR\] No Verilog file selected!\n"
        .output_frame.output_text see end
        return
    }
    
    # Create a temporary config file with advanced parameters
    set config_file "advanced_config.tcl"
    set f [open $config_file w]
    puts $f "set MAX_ITERATIONS $max_iterations"
    puts $f "set TARGET_SLACK $target_slack"
    puts $f "set MIN_CLOCK $min_clock"
    puts $f "set MAX_CLOCK $max_clock"
    close $f
    
    set filepath "\"$verilog_file\""
    set command "perl advanced_synthesize.pl --file $filepath --clock $clock_period --power $power_budget --area $area_budget"
    
    .output_frame.output_text insert end "\nStarting advanced synthesis with constraints...\n"
    .output_frame.output_text insert end "Clock: ${clock_period}ns, Power: ${power_budget}mW, Area: ${area_budget} LUTs\n"
    .output_frame.output_text insert end "Advanced Params: Max Iter=$max_iterations, Target Slack=${target_slack}ns, Clock Range=${min_clock}-${max_clock}ns\n"
    .output_frame.output_text see end
    
    if {[catch {exec sh -c $command} output]} {
        .output_frame.output_text insert end "\n\[ERROR\] Advanced synthesis failed:\n$output\n"
    } else {
        .output_frame.output_text insert end "\n\[Advanced Synthesis Output\]\n$output\n"
        
        # Show optimization results if available
        if {[file exists "optimized_constraints.txt"]} {
            set f [open "optimized_constraints.txt" r]
            set opt_results [read $f]
            close $f
            .output_frame.output_text insert end "\n\[Optimization Results\]\n$opt_results\n"
            
            # Update best configuration display
            set best_config $opt_results
        }
    }
    .output_frame.output_text see end
}

proc open_gtkwave {} {
    global verilog_file
    set vcd_file [file rootname $verilog_file].vcd

    if {![file exists $vcd_file]} {
        .output_frame.output_text insert end "\n\[ERROR\] No waveform file found: $vcd_file\n"
        .output_frame.output_text see end
        return
    }

    if {[catch {exec sh -c "gtkwave $vcd_file &"} err]} {
        .output_frame.output_text insert end "\n\[ERROR\] Failed to open GTKWave:\n$err\n"
    } else {
        .output_frame.output_text insert end "\n\[INFO\] Opening GTKWave for $vcd_file...\n"
    }
    .output_frame.output_text see end
}

proc show_report {} {
    set report_files {
        {"Basic Synthesis" "report.log"}
        {"Advanced Synthesis" "advanced_report.log"}
        {"Timing" "timing_report.txt"}
        {"Power" "power_report.txt"}
        {"Area" "area_report.txt"}
    }
    
    set found 0
    
    foreach pair $report_files {
        set title [lindex $pair 0]
        set file [lindex $pair 1]
        
        if {[file exists $file]} {
            set found 1
            .output_frame.output_text insert end "\n\[$title Report\]\n"
            
            set f [open $file r]
            while {[gets $f line] >= 0} {
                .output_frame.output_text insert end "$line\n"
            }
            close $f
        }
    }
    
    if {!$found} {
        .output_frame.output_text insert end "\n\[ERROR\] No report files found!\n"
    }
    
    .output_frame.output_text see end
}

puts "Advanced Verilog Design Flow GUI Loaded Successfully"
