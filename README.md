# VLSI-Traffic-Light-FSM
# FPGA Traffic Light Controller Using Verilog HDL

## Project Overview

This project implements a two-road traffic light controller using **Verilog HDL and a Moore Finite State Machine (FSM)**. The controller manages the traffic signals for two intersecting roads, Road A and Road B, by cycling through green, yellow, and red light combinations in a predefined sequence.

The design uses a clock divider to generate a one-second timing pulse from the FPGA's high-frequency clock. A countdown timer uses this pulse to control the duration of each traffic-light state. The controller also incorporates dedicated all-red states between the traffic phases to provide a clearance interval before traffic is permitted to move in the opposite direction.

The project demonstrates the practical application of digital design concepts, including finite state machines, sequential and combinational logic, clock division, countdown timers, parameterization, and RTL design using Verilog HDL.

## Objectives

* Design a reliable two-road traffic light controller using a Moore FSM.
* Implement a clock divider to generate a one-second timing reference.
* Develop a countdown timer for controlling the duration of each traffic signal.
* Implement configurable green, yellow, and all-red durations.
* Introduce all-red transition phases between opposing traffic directions.
* Use clear state encoding and combinational output decoding.
* Develop a design suitable for RTL simulation and potential FPGA implementation.

## System Architecture

The controller consists of three main logical blocks:

### 1. Clock Divider

The clock divider converts the high-frequency FPGA clock into a periodic one-second enable pulse. With the default configuration of 50 MHz, the divider counts 50,000,000 clock cycles per second.

The generated pulse enables the countdown timer to update once per second without requiring a separate derived clock for the FSM.

### 2. Finite State Machine and Countdown Timer

The FSM determines the current traffic-light phase and selects the next phase when the countdown timer expires.

The timer loads a duration according to the upcoming state and decrements on each one-second tick. Once the timer reaches zero, the controller transitions to the next state.

### 3. Moore Output Logic

The output logic decodes the current state and generates the appropriate light patterns for Road A and Road B.

Since this is a Moore FSM, the traffic-light outputs depend only on the current state.

## Traffic-Light Sequence

The controller uses six states in the following repeating sequence:

| State         | Road A | Road B | Duration   |
| ------------- | ------ | ------ | ---------- |
| `S0_A_GREEN`  | Green  | Red    | 10 seconds |
| `S1_A_YELLOW` | Yellow | Red    | 5 seconds  |
| `S2_ALL_RED1` | Red    | Red    | 10 seconds |
| `S3_B_GREEN`  | Red    | Green  | 10 seconds |
| `S4_B_YELLOW` | Red    | Yellow | 5 seconds  |
| `S5_ALL_RED2` | Red    | Red    | 10 seconds |

After the second all-red state, the controller returns to the initial A GREEN state and repeats the sequence.

With the default parameters, the complete cycle lasts 50 seconds.

## State Machine Design

The FSM uses a three-bit state register to represent six traffic-light states.

The state transitions follow this sequence:

`A_GREEN → A_YELLOW → ALL_RED → B_GREEN → B_YELLOW → ALL_RED → A_GREEN`

The initial state is `S0_A_GREEN`, selected when reset is asserted at a rising edge of the clock.

The design separates sequential state and timer updates from combinational next-state logic and output decoding. This structure improves readability and makes the design easier to maintain, simulate, and extend.

## Configurable Parameters

The controller supports parameterized timing values.

| Parameter       | Default value | Description                      |
| --------------- | ------------: | -------------------------------- |
| `CLOCK_FREQ_HZ` |  `50_000_000` | Input clock frequency in hertz   |
| `GREEN_TIME`    |          `10` | Green-light duration in seconds  |
| `YELLOW_TIME`   |           `5` | Yellow-light duration in seconds |
| `ALL_RED_TIME`  |          `10` | All-red duration in seconds      |

These parameters can be changed during module instantiation to adapt the controller to different clock frequencies and timing requirements.

The input clock frequency must match the actual FPGA board clock for the timing to be accurate. All phase-duration parameters should be positive integers.

## Input and Output Signals

| Signal   | Direction | Width  | Description                   |
| -------- | --------- | ------ | ----------------------------- |
| `clk`    | Input     | 1 bit  | Main FPGA clock               |
| `rst`    | Input     | 1 bit  | Synchronous active-high reset |
| `road_A` | Output    | 3 bits | Traffic signals for Road A    |
| `road_B` | Output    | 3 bits | Traffic signals for Road B    |

Both road outputs use the bit ordering `{RED, YELLOW, GREEN}`.

The signal encodings are:

* `3'b100` — Red
* `3'b010` — Yellow
* `3'b001` — Green

These encodings assume active-high outputs, where a logic HIGH turns on the corresponding light.

## Key Features

* **Moore FSM architecture:** Outputs depend only on the current state.
* **Clock divider:** Generates a one-second timing pulse from the FPGA clock.
* **Countdown timer:** Controls the duration of each traffic-light phase.
* **Parameterized timing:** Supports configurable clock frequency and signal durations.
* **All-red transition states:** Provides an explicit clearance phase between opposing directions.
* **Safe default output decoding:** Unhandled state encodings produce red outputs for both roads.
* **Synchronous reset:** Initializes the controller to Road A GREEN.
* **Modular RTL structure:** Separates timing, state transitions, and output decoding.

## Simulation and Verification

The design can be verified using a Verilog simulator such as Icarus Verilog, QuestaSim, ModelSim, or Vivado Simulator.

A testbench can validate the reset behavior, traffic-light sequence, state durations, and output combinations. For faster simulation, the clock frequency parameter can be reduced to a small value, such as 10 Hz, so each simulated second requires only ten clock cycles.

Useful verification checks include:

1. The controller starts in A GREEN after reset.
2. The states occur in the intended order.
3. Each state remains active for its configured duration.
4. Both roads are never green simultaneously.
5. The controller returns to A GREEN after completing a cycle.
6. Invalid state values produce the default red-light output combination.

## Technologies Used

* **Hardware Description Language:** Verilog HDL
* **Design methodology:** RTL design
* **Digital design concept:** Moore Finite State Machine
* **Timing mechanism:** Clock divider and countdown timer
* **Verification:** Verilog testbench and RTL simulation
* **Target platform:** FPGA, subject to synthesis, timing constraints, and board-specific integration

## Applications

This project can be used as an educational example for understanding FSM-based digital controllers, timing circuits, RTL coding practices, and FPGA development workflows.

It can also serve as a starting point for extended designs involving pedestrian crossings, emergency-vehicle priority, configurable operating modes, sensor inputs, and more advanced traffic-control strategies.

## Future Enhancements

Potential extensions include:

* Pedestrian crossing request and control.
* Emergency vehicle priority.
* Adjustable signal timings through switches or a communication interface.
* Seven-segment display for countdown visualization.
* Sensor-based traffic density detection.
* Automatic FSM recovery and additional fault monitoring.
* Improved verification through assertions and automated timing checks.

## Conclusion

The FPGA Traffic Light Controller demonstrates how a finite state machine, clock divider, and countdown timer can be integrated to create a parameterized digital control system using Verilog HDL. Its modular structure provides a foundation for learning sequential logic design, RTL simulation, and FPGA-based control applications.

**Note:** This is an educational RTL project, not a certified traffic-control system. The default all-red duration and other timing values are illustrative and must be validated against appropriate requirements before any real-world deployment.
