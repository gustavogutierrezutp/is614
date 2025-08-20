# Lab Session 2: Sequential Circuits, Clocks, and FSMs

## Objectives

- Understand the role of the system clock in synchronous circuits.
- Design and implement a **frequency divider** (clock divider) to slow down the 50 MHz clock signal.
- Introduce the concept of **Finite State Machines (FSMs)** to control the behavior of a circuit.
- Implement a synchronous counter with control features (reset, pause/resume, and speed control).

---

## 1. Board Components and Pin Assignments

For this lab, we will continue to use the switches, push-buttons, and 7-segment displays. The key new component is the board's internal **50 MHz clock**.

You can find the official user manual for the board at the following link. **The complete pin assignment list for all components can be found on page 20.**

- [DE1-SoC User Manual](http://www.ee.ic.ac.uk/pcheung/teaching/ee2_digital/de1-soc_user_manual.pdf)

---

## 2. Theoretical Background

Unlike the combinational circuits from the previous lab, sequential circuits have **memory**. Their output depends not only on the current inputs but also on previous states. The component that orchestrates this memory is the **system clock**.

- **System Clock:** The DE1-SoC has a 50 MHz crystal oscillator that provides the main clock signal. This means 50 million cycles per second. For human-interactive applications, like a visible counter, this speed is far too high, and we must "slow it down" using a **frequency divider**.

- **Finite State Machines (FSM):** An FSM is a design model that describes the behavior of a system through a finite number of states, the transitions between those states, and the actions performed in each one. It is a fundamental tool for designing any digital control system.

---

## 3. Exercise: Multi-Function Synchronous Counter

In this lab, you will design a **hexadecimal counter** from **`00` to `FF`** that will be shown on two 7-segment displays (`HEX1` and `HEX0`). This will require an 8-bit binary counter, where the upper 4 bits control `HEX1` and the lower 4 bits control `HEX0`.

The counter will have the following features, which you will control using the board's switches and push-buttons:

- **Clock Source:** You must use the board's 50 MHz clock (`CLOCK_50`).
- **Normal Count:** The counter should increment its value every **1 second**. To achieve this, you will design a frequency divider module to generate a 1 Hz signal.
- **Reset Button:** `KEY0` will act as a synchronous or asynchronous reset. When pressed, the counter must return to **`00`** immediately.
- **Pause/Resume Button:** `KEY1` will pause the count if it's running and resume it if it's paused. This is the core of your FSM.
- **Speed Control:** `SW9` will control the counting speed.
  - If `SW9` is **0** (down), the counter will run at normal speed (1 Hz).
  - If `SW9` is **1** (up), the counter will run at a fast speed (e.g., 10 Hz).

### 3.1 The Frequency Divider Module

The first step is to create a SystemVerilog module that takes the `CLOCK_50` as input and generates two clock outputs: `clk_1Hz` and `clk_10Hz`.

* **Hint:** A frequency divider is essentially a counter. To get 1 Hz from 50 MHz, you need to count up to 25,000,000 (for a 50% duty cycle signal) or 50,000,000 (for a single-cycle pulse).

### 3.2 The Finite State Machine (FSM) Module

Design the main control module as an FSM. This FSM will receive inputs from the push-buttons (`KEY0`, `KEY1`) and decide the counter's behavior. It should have at least two states, such as `COUNTING` and `PAUSED`.

### 3.3 Integration and 7-Segment Output

Integrate your modules:
1. The frequency divider generates the clock pulses.
2. A multiplexer controlled by `SW9` selects whether to use the 1 Hz or 10 Hz pulse.
3. The FSM decides if the counter should increment or hold its value on the next selected clock edge.
4. The counter's value is sent to the 7-segment display decoders you designed in the previous lab to be displayed on `HEX1` and `HEX0`.

---

## 4. Deadline
-  (Implementation):** The deadline to demonstrate the working circuit on the DE1-SoC board is `----`.
