# 4-Bit SISO Shift Register (Verilog)

A 4-bit **Serial-In, Serial-Out (SISO) shift register** implemented in Verilog and verified with a self-checking testbench using Icarus Verilog. GTKWave can be used to inspect the generated timing waveform.

## Overview

A shift register stores bits and moves them by one position on each active clock edge. This project implements a four-stage register:

- One serial data input: `serial_in`
- Four register bits: `q[3:0]`
- One serial output: `q[3]`
- Positive-edge-triggered clock: `clk`
- Synchronous, active-high reset: `rst`

The register shifts toward the most-significant bit. On each rising edge when reset is low:

```verilog
q <= {q[2:0], serial_in};
```

In other words:

| Next-state bit | Value sampled at the rising edge |
| --- | --- |
| `q[3]` | Previous `q[2]` |
| `q[2]` | Previous `q[1]` |
| `q[1]` | Previous `q[0]` |
| `q[0]` | `serial_in` |

When `rst = 1` at a rising clock edge, `q` is cleared to `4'b0000`. Because reset is synchronous, asserting reset between clock edges does not immediately change `q`.

## Repository structure

```text
4-bit-shift-register/
├── rtl/
│   └── shift_register.v       # Synthesizable design
├── tb/
│   └── shift_register_tb.v    # Self-checking testbench
├── sim/                       # Generated simulation outputs (ignored by Git)
└── .gitignore
```

## Requirements

The project uses open-source tools:

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) — compile and run the simulation
- [GTKWave](https://gtkwave.sourceforge.net/) — view the VCD waveform

On Ubuntu/Debian, install them with:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

## Run the simulation

Run these commands from the repository root:

```bash
mkdir -p sim
iverilog -g2012 -o sim/shift_sim rtl/shift_register.v tb/shift_register_tb.v
vvp sim/shift_sim
```

Expected successful output:

```text
VCD info: dumpfile sim/shift_register.vcd opened for output.
ALL TESTS PASSED!
```

The testbench checks the reset value and each successive shifted value. It uses case inequality (`!==`) so unknown or high-impedance bits also cause a test failure.

## Test sequence and expected values

The testbench applies the serial input sequence `1, 0, 1, 1`, changing the input on falling clock edges so it is stable before the next rising edge.

| Step | Serial input | Register value `q[3:0]` |
| --- | ---: | --- |
| Synchronous reset | — | `0000` |
| 1 | 1 | `0001` |
| 2 | 0 | `0010` |
| 3 | 1 | `0101` |
| 4 | 1 | `1011` |

After the four input bits have been shifted in, `q[3]` contains the oldest bit in this sequence and is the serial output.

## View the waveform

The testbench writes a Value Change Dump file to `sim/shift_register.vcd`.

```bash
gtkwave sim/shift_register.vcd
```

In GTKWave, add these signals from the `shift_register_tb` scope:

- `clk`
- `rst`
- `serial_in`
- `q[3:0]` (expand the bus if desired)

The register output should change only on rising clock edges. The waveform is generated locally and is not committed to the repository.

## Design notes

- The RTL uses a positive-edge-triggered sequential block: `always @(posedge clk)`.
- Non-blocking assignment (`<=`) models simultaneous flip-flop state updates.
- The reset is synchronous and active high.
- No initial value is assumed for the register; the testbench applies reset before checking shifted data.
- This is a functional RTL simulation. It does not by itself demonstrate timing closure, FPGA implementation, or ASIC physical design.

## Future extensions

Possible follow-on exercises:

1. Add a SIPO version with parallel outputs.
2. Add a PISO version with parallel load.
3. Add a PIPO register.
4. Parameterize the register width.
5. Add more test cases, including reset asserted during shifting.
