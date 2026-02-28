# Lab Session: 6-Digit Multi-Mode Counter on the DE1-SoC

## Objectives

- Implement a **frequency divider** to convert the 50 MHz system clock to a 1 Hz signal.
- Design a 6-digit counter with **Dual-Mode Visualization**: Decimal and Hexadecimal.
- Use a **Control Switch** to toggle between counting bases (Base 10 vs. Base 16).
- Master the use of conditional assignments and multiplexing logic in SystemVerilog.

---

## 1. Getting Started

### Materials Required

- DE1-SoC FPGA development board.
- USB cable for programming and Power cable.
- Computer with **Intel Quartus Prime**.

---

## 2. Hardware Mapping

To successfully implement this circuit, you must identify and assign the following FPGA resources using the **DE1-SoC User Manual**:

- **System Clock**: The 50 MHz primary oscillator input.
- **Master Reset**: Use one of the onboard push-buttons (**KEY**). Note that these are typically active-low.
- **Mode Selector**: Use one of the user switches (**SW**).
- **Outputs**: All six 7-segment displays (**HEX0** to **HEX5**).

---

## 3. Implementation Logic

### 3.1 Frequency Division
The system clock runs at a high frequency (50 MHz). Your design must include a counter that tracks the number of cycles elapsed to generate a precise pulse exactly every **1.0 seconds**.



### 3.2 Dual-Mode Visualization
The core challenge is to change the data representation based on the state of your mode switch:

1.  **Decimal Mode**: 
    - The counter value must be decomposed into its constituent decimal digits (Units, Tens, Hundreds, etc.) using arithmetic operations.
2.  **Hexadecimal Mode**: 
    - The counter value must be sliced into 4-bit groups (nibbles), where each group represents a single Hex digit.



---

## 4. Exercises

### 4.1 Hexadecimal 7-Segment Decoder
Create a module that translates a 4-bit binary input into the 7-bit pattern required by the board. This decoder must support digits `0-9` and letters `A-F`.

### 4.2 24-bit Synchronous Counter
Define a counter register wide enough to hold the maximum value of 6 Hexadecimal digits ($FFFFFF_{16}$). Ensure the counter increments only when the 1-second pulse is triggered.

### 4.3 Mode Selection (Muxing)
Implement logic that selects between the Decimal-decomposed digits and the Hexadecimal-sliced nibbles before sending them to the 7-segment displays.

