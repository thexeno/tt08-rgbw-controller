# Testbench for TT08 RGBW Controller

This testbench uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.
See below to get started or for more information, check the [website](https://tinytapeout.com/hdl/testing/).

## What is testing

This testbench runs a sequence between different color modes, and outputs 4 PWM sequences as a result. Data is not automatically asserted, but waveforms were inspected manually in this first implementation.
The RTL waveforms (in .vcd format) are always tested against the flattened gate-level (hardened) design to evaluate the correctness of the design.

For more info in the design, check [the documentation](docs/info.md).

Here below a quick run up of the flow if needed to interact with the testbench.

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to point to your Verilog files.
2. Edit [tb.v](tb.v) and replace `tt_um_example` with your module name.

## How to run

### To run the RTL simulation:

```sh
make -B
```
A .vcd containing the waveforms is generated and can be instepcted with a waveform analyzer, i.e. GTKwave.

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/{your_module_name}.v` to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

### If you don't have a locally hardened project:

Download from the GitHub actions the gate level .vcd, and replace the previously generated .vcd with this one. Then run the same ```make -B``` command.


## How to view the VCD file

```sh
gtkwave tb.vcd tb.gtkw
```
