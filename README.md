# Advanced Verilog EDA Design Flow GUI & Automation Toolsuite

[![Tcl/Tk](https://img.shields.io/badge/GUI-Tcl%2FTk_Wish-blue.svg)](https://www.tcl.tk/)
[![Perl](https://img.shields.io/badge/Automation-Perl_5-teal.svg)](https://www.perl.org/)
[![Python](https://img.shields.io/badge/Analytics-Python_3_Matplotlib-green.svg)](https://www.python.org/)
[![EDA](https://img.shields.io/badge/EDA-Icarus_Verilog_%7C_GTKWave_%7C_Vivado-orange.svg)](#eda-toolchain-integration)

An integrated EDA automation suite and graphical interface designed to streamline the digital ASIC/FPGA design flow. Combines a **Tcl/Tk graphical interface (`wish`)**, **Perl-driven orchestration scripts**, and **Xilinx Vivado batch-mode automation** for one-click compilation, simulation, waveform visualization, iterative constraint-driven synthesis, timing closure optimization, and automated convergence plotting.

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [EDA Toolchain Integration](#eda-toolchain-integration)
- [Key Features & Capabilities](#key-features--capabilities)
- [Automated Optimization Engine](#automated-optimization-engine)
- [GUI Walkthrough & Controls](#gui-walkthrough--controls)
- [Prerequisites & System Requirements](#prerequisites--system-requirements)
- [Quickstart Guide](#quickstart-guide)
- [File & Directory Structure](#file--directory-structure)

---

## Architecture Overview

```
                      +---------------------------------------+
                      |     Advanced Verilog GUI (Tk/Tcl)     |
                      |          (verilog_gui.tcl)            |
                      +---------------------------------------+
                         |                 |               |
         +---------------+                 |               +---------------+
         |                                 |                               |
         v                                 v                               v
[Compile & Simulate]             [Advanced Synthesis]             [Metrics & Plots]
 `compile_and_simulate.pl`      `advanced_synthesize.pl`            `plot_report.py`
         |                                 |                               |
    iverilog / vvp                  Vivado Batch Mode                  matplotlib
         |                       (`vivado_analysis.tcl`)                   |
         v                                 |                               v
 [GTKWave Viewer]                          v                        [Convergence Charts]
  (.vcd waveform)               - Iterative Timing Closure           (Slack, LUTs, Power)
                                - SDC Optimization
                                - CSV Report Logging
```

---

## EDA Toolchain Integration

| Stage | Script / Module | Underlying Engine | Artifacts Produced |
|:---|:---|:---|:---|
| **Compilation** | `compile_and_simulate.pl` | Icarus Verilog (`iverilog`) | `simulation.vvp` |
| **Simulation** | `compile_and_simulate.pl` | `vvp` runtime | `sample.vcd`, `report.log` |
| **Waveform View** | `verilog_gui.tcl` (Callback) | `gtkwave` | Interactive waveform trace |
| **Basic Synthesis** | `synthesize.pl` | Xilinx Vivado CLI | `timing_report.txt`, `area_report.txt` |
| **Timing Closure** | `advanced_synthesize.pl` | Vivado TCL batch (`vivado_analysis.tcl`) | `optimized_constraints.sdc`, `report_data.csv` |
| **Visual Analytics**| `plot_report.py` | Python (`pandas`, `matplotlib`) | Convergence plots across iterations |

---

## Key Features & Capabilities

- **Interactive GUI Dashboard:** Unified workbench for RTL designers avoiding manual command-line typing.
- **Automated Iterative Timing Closure:**
  - Performs multi-iteration search loops to find the maximum operating frequency ($F_{\max}$).
  - Automatically sweeps clock periods while verifying Worst Negative Slack ($WNS \ge 0.1\text{ ns}$).
  - Enforces power budgets ($\text{mW}$) and maximum LUT count limits.
- **SDC Constraint Generation:** Generates valid Synopsys Design Constraints (`.sdc`) and Vivado constraint files (`.tcl`) dynamically based on user parameters.
- **Integrated Report Viewer:** Summarizes timing, power, and area utilization logs directly within the GUI console.

---

## Automated Optimization Engine

The advanced synthesis script (`advanced_synthesize.pl`) automates design space exploration:
1. Formulates timing constraints:
   $$\text{Clock Frequency Target } f = \frac{1}{T_{\text{period}}}$$
2. Runs Vivado batch synthesis:
   ```bash
   vivado -mode batch -source vivado_analysis.tcl -tclargs <verilog_file> <clock_period>
   ```
3. Parses post-synthesis slack ($WNS$), dynamic power, and cell usage (LUTs/FFs).
4. Adaptively adjusts the clock constraint toward target slack while checking constraints:
   - If Slack $> \text{Target Slack}$: Decreases clock period (pushes for higher frequency).
   - If Slack $< 0$ (Timing Violation): Relaxes clock period to achieve closure.
5. Emits optimized parameters into `optimized_constraints.txt` and records history into `report_data.csv`.

---

## GUI Walkthrough & Controls

- **Verilog File Selector:** Selects target RTL design (e.g., `counter.v` or `sample.v`).
- **Constraint Inputs:**
  - *Clock Period (ns):* Initial target clock cycle.
  - *Power Budget (mW):* Maximum allowable chip power.
  - *Area Budget (LUTs):* Maximum logic utilization limit.
- **Optimization Parameters:**
  - *Max Iterations:* Maximum search trials (default: 20).
  - *Target Slack (ns):* Positive timing safety margin (default: 0.1 ns).
  - *Min / Max Clock (ns):* Search range limits.
- **Actions:**
  - `Compile & Simulate`: Compiles and executes testbench.
  - `View Waveform`: Launches GTKWave for `.vcd` inspection.
  - `Run Synthesis`: Runs single-pass baseline Vivado synthesis.
  - `Advanced Optimization`: Starts iterative timing/area search loop.
  - `Plot Metrics`: Generates graphical performance trends.

---

## Prerequisites & System Requirements

### Linux Packages
```bash
sudo apt-get update
sudo apt-get install tk tcl iverilog gtkwave perl python3 python3-matplotlib python3-pandas
```

### Synthesis Tool
- **Xilinx Vivado** (ensure `vivado` is available in your system `$PATH`).

---

## Quickstart Guide

1. Clone repository and navigate to folder:
   ```bash
   cd Scripting_project
   ```

2. Launch the GUI:
   ```bash
   wish verilog_gui.tcl
   ```

3. Alternatively, execute headless command-line workflows:
   ```bash
   # Simulation:
   perl compile_and_simulate.pl --file sample.v

   # Iterative timing optimization:
   perl advanced_synthesize.pl --file sample.v --clock 10.0 --power 100 --area 1000

   # Plot results:
   python3 plot_report.py
   ```

---

## File & Directory Structure

```text
Scripting_project/
├── verilog_gui.tcl            # Tk/Tcl Graphical User Interface
├── compile_and_simulate.pl    # Icarus Verilog compilation & test runner
├── synthesize.pl              # Baseline single-pass Vivado synthesis script
├── advanced_synthesize.pl     # Iterative timing optimization engine
├── vivado_analysis.tcl        # Vivado batch mode synthesis & reporting TCL
├── plot_report.py             # Python report & optimization plotting script
├── counter.v                  # Sample parameterized counter design
├── sample.v                   # Sample Verilog design
├── sample.vcd                 # Generated simulation waveform
├── design_constraints.sdc     # Baseline SDC timing constraints
├── optimized_constraints.tcl  # Generated optimal Vivado constraints
├── report_data.csv            # Optimization iterations log
└── README.md                  # Comprehensive toolsuite documentation
```
