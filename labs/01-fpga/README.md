# Lab Session: Introduction to FPGA using the DE1-SoC Board


## by Diego Amaya, Group 101.

## This repository contains the solution for Section 4 of the laboratory.

## Project description.

The project has two main files:

- **top_level.sv**: main module of the design.

- **top_level_tb.sv**: testbench used to simulate and verify the design.

## Evidences.

There is a folder called [Evidences](https://github.com/Aeae21/IS614/tree/main/labs/01-fpga/Evidences).

This folder contains all the images and waveforms that show the correct operation of each exercise.

## Solved Exercises.

### 4.1 LED reflection

In the [Evidence 4.1.](https://github.com/Aeae21/IS614/blob/main/labs/01-fpga/Evidences/4.1%20LED%20reflection.png), all switches are ON (`1111111111`), and all LEDs are also ON (`1111111111`). This shows that the state of every switch is reflected correctly on the corresponding LED.

### 4.2 Hexadecimal display on seven-segment display

In the [Evidence 4.2.](https://github.com/Aeae21/IS614/blob/main/labs/01-fpga/Evidences/4.2%20Hexadecimal%20display%20on%20seven-segment%20display.png), the first four switches change state, and `HEX0` lights up according to the binary input. The value shown corresponds to the segments of the display (active-low), not directly the number, but it works correctly because each input is converted to its hexadecimal digit and displayed.

### 4.3 Bigger numbers, still positive

In the [Evidence 4.3.](https://github.com/Aeae21/IS614/blob/main/labs/01-fpga/Evidences/4.3%20Bigger%20numbers%2C%20still%20positive.png), the largest input `1111111111 (decimal 1023)` is displayed across four seven-segment displays. The segment values `HEX3 = 1000000` ; `HEX2 = 01100000` ; `HEX1 = 0001110` ; `HEX0 = 0001110`, correspond to hexadecimal `03FF`, which is the correct representation of `1023` in hexadecimal.

### 4.4 Negative numbers

In the last two images, the circuit toggles between `signed` and `unsigned` interpretation using `KEY0`:

- **KEY0 = 0 (pressed)**: [Evidence 4.4.1](https://github.com/Aeae21/IS614/blob/main/labs/01-fpga/Evidences/4.4%20Negative%20numbers%20(Button%20pressed%200).png), the number is `unsigned`. For input `1111111110`, the value is `03FE` (decimal `1022`).

- **KEY0 = 1 (unpressed)**: [Evidence 4.4.2](https://github.com/Aeae21/IS614/blob/main/labs/01-fpga/Evidences/4.4%20Negative%20numbers%20(Button%20unpressed%201).png), the number is `signed` (two's complement). The same input `1111111110` is interpreted as `FFFE (decimal −2)`.

This confirms that the circuit correctly switches between positive-only and signed interpretation modes.
