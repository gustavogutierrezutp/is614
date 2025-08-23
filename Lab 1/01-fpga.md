# Lab Session: Introduction to FPGA using the DE1-SoC Board

## Objectives

- Understand the basics of Field Programmable Gate Arrays (FPGA), specifically the Cyclone V SoC FPGA.
- Familiarize with the DE1-SoC hardware and software tools.
- Create, simulate, and implement a basic digital circuit on the Cyclone V FPGA
  using Quartus Prime and SystemVerilog.

---

## 1. Getting Started

### Materials Required

- DE1-SoC FPGA development board
- USB cable for programming
- Power cable for DE1-SoC
- Computer with **Intel Quartus Prime**.

---
## 2. DE1-SoC Board Overview

The DE1-SoC features an **Altera Cyclone V SoC 5CSEMA5F31C6 FPGA** device. This
includes:
  - 85K programmable logic elements
  - 4,450 Kbits embedded memory
  - A dual-core ARM Cortex-A9 Hard Processor System (HPS) integrated in the SoC

For this lab, we will work with the FPGA fabric part only, utilizing onboard
switches, push-buttons, LEDs, and 7-segment displays to visualize logic.  Major
board components connected to the FPGA:
  - 10 User switches (SW0 to SW9)
  - 4 Debounced push-buttons (KEY0 to KEY3) — These push-buttons generate a low
    logic level when pressed and high when released, making them suitable for
    clock or reset inputs in circuits.
  - 10 User LEDs (LED0 to LED9)
  - Six 7-Segment Displays — Each display can be controlled to show hexadecimal
    digits or custom characters, useful for numeric output visualization.

Further information can be found in the [DE1-SoC User Manual (rev. E) -
Terasic](https://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/DE1-SoC_User_manualv.1.2.2_revE.pdf)

## 3. Lab preparation

1. **Lab Template** 
   
   In [this repository](https://github.com/gustavogutierrezutp/is614) you will
   finde both the source of this document and the files you will work with. In
   this case got to the folder `labs/01-fpga`.

2. **Open Quartus Prime**
   
   Launch Quartus and open the provided project file (e.g., `fpga.qpf`). This
   project contains a simple _and gate_  circuit run it and make sure you get
   the expected funtionality on the FPGA. 

3. **Simulation**

## 4. Exercises

### 4.1 LED reflection

The first exercise you will try is to reflect the sate of every switch on the
corresponding LED. For example, if SW0 is pressed, LED0 should light up. Modify
the `top_level.sv` file to implement this functionality.

### 4.2 Hexadecimal display on seven-segment display

In this exercise, you will use the first four switches (SW0 to SW3) on the
DE1-SoC board to represent a 4-bit binary number. Your task is to design and
implement a circuit that converts this 4-bit binary input into a hexadecimal
value and displays it on the first seven-segment display (HEX0) of the board.

For this you will have to:
- Read the state of the first four switches as a binary number.
- Convert the binary number to its corresponding hexadecimal digit (0 through F).
- Display the hexadecimal digit on HEX0 using the seven-segment display.
- Remember that the seven-segment display on the DE1-SoC is active-low (a
  segment lights when driven low).

### 4.3 Bigger numbers, still positive

Now that you have your circuit working, you will extend it to convert any binary
encoded in the ten switches (SW0 to SW9) into its hexadecimal representation.
Now you will use all the seven-segment displays that you need.

### 4.3 Negative numbers

For this part you will assume your number is a signed number, so you will
implement a two's complement converter and your display will show the
corresponding negative number. As there are two ways to interpret a number in
binary we will use a push-button (KEY0) to toggle between the two
representations. So the expected behavior of your final circuit is:

- When KEY0 is pressed, the circuit will toggle interprate the number encoded by
  the switches as unsigned (always positive) and will display it.
- When KEY0 is not pressed, the circuit will interpret the number as signed
  (two's complement) and will display the corresponding value.
  

## 5. Deadline

You will submit your work in two parts:

- **Part 1**: By next thursday, August 22 (23:59 COT) you will create a pull request
  with your answers and a simulation of your circuit.

- **Part 2**: After that you will contact out teaching assistant and schedule
  a time to test your circuit on the DE1-SoC board. The strict deadline for
  this is August 27.

