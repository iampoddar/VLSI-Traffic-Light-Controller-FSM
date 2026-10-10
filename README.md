# VLSI-Traffic-Light-Controller-FSM

# Project Overview

This project presents a traffic signal control system for a two-road intersection, developed using **Verilog HDL and a Moore Finite State Machine (FSM)**. It coordinates the traffic lights on Road A and Road B by switching between red, yellow, and green signals according to a predefined operating sequence.

A clock divider generates a one-second enable pulse from the FPGA's high-frequency clock, allowing a countdown timer to track the duration of each signal phase. The design also includes dedicated all-red phases between the two roads' traffic movements, providing a clearance period before the opposite road receives a green signal.

The project highlights several fundamental digital design techniques, such as FSM implementation, sequential and combinational logic, clock division, countdown-based timing, parameterized design, and Register Transfer Level (RTL) development using Verilog HDL.

## Project Objectives

* Develop a two-road traffic signal controller based on a Moore FSM.
* Generate a one-second timing pulse using a clock-divider circuit.
* Implement a countdown mechanism to determine the duration of each signal phase.
* Allow green, yellow, and all-red intervals to be configured through parameters.
* Include all-red intervals when switching between the two traffic directions.
* Organize the state encoding and output-decoding logic for clarity and maintainability.
* Create an RTL design suitable for simulation and potential deployment on an FPGA.

## System Architecture

The traffic controller is organized into three primary functional sections.

### 1. Clock Divider

The clock divider scales the FPGA's high-frequency clock into a one-second enable pulse. For the default 50 MHz clock, it counts 50,000,000 clock cycles to produce each timing pulse.

This pulse allows the countdown timer to update at one-second intervals while keeping the FSM synchronized to the original FPGA clock. As a result, the design does not need a separate generated clock for the traffic controller.

### 2. Finite State Machine and Countdown Timer

The FSM manages the current traffic-light phase and determines which phase should follow when the current interval ends.

At the beginning of each phase, the countdown timer is loaded with the appropriate duration. It then decreases by one on every one-second pulse. When the counter reaches zero and the next timing pulse arrives, the FSM advances to the next state and loads the corresponding timer value.

### 3. Moore FSM Output Logic

The output-decoding logic translates the current FSM state into the required light combinations for Road A and Road B.

Because the controller follows the Moore FSM model, its traffic-light outputs are determined entirely by the active state.

## Traffic Signal Operating Sequence

The controller progresses through six states in a continuous loop:

| **State**     | **Road A Signal** | **Road B Signal** | **Duration** |
| ------------- | ----------------- | ----------------- | ------------ |
| `S0_A_GREEN`  | Green             | Red               | 10 seconds   |
| `S1_A_YELLOW` | Yellow            | Red               | 5 seconds    |
| `S2_ALL_RED1` | Red               | Red               | 10 seconds   |
| `S3_B_GREEN`  | Red               | Green             | 10 seconds   |
| `S4_B_YELLOW` | Red               | Yellow            | 5 seconds    |
| `S5_ALL_RED2` | Red               | Red               | 10 seconds   |

Once the second all-red phase finishes, the controller returns to `S0_A_GREEN` and begins the cycle again.

Using the default timing configuration, one complete sequence takes 50 seconds.

## FSM Design and State Transitions

A three-bit register is used to represent the six operating states of the traffic controller.

The transition order is:

`A_GREEN → A_YELLOW → ALL_RED → B_GREEN → B_YELLOW → ALL_RED → A_GREEN`

When the synchronous reset is asserted at a rising edge of the clock, the FSM initializes to `S0_A_GREEN`, making Road A green and Road B red.

The design separates clocked operations, such as state and timer updates, from combinational operations, such as next-state selection and output decoding. This organization improves code readability and makes the controller easier to test, maintain, and extend with additional functionality.

## Configurable Design Parameters

The controller uses parameters to define its operating clock frequency and traffic-signal durations.

| **Parameter**   | **Default Setting** | **Purpose**                                       |
| --------------- | ------------------: | ------------------------------------------------- |
| `CLOCK_FREQ_HZ` |        `50_000_000` | Specifies the FPGA input clock frequency in hertz |
| `GREEN_TIME`    |                `10` | Sets the green-light interval in seconds          |
| `YELLOW_TIME`   |                 `5` | Sets the yellow-light interval in seconds         |
| `ALL_RED_TIME`  |                `10` | Defines the all-red clearance interval in seconds |

These values can be overridden when the module is instantiated, making it possible to adapt the design to different FPGA clock rates or timing specifications.

For accurate timing, `CLOCK_FREQ_HZ` must correspond to the actual clock frequency of the target FPGA board. Each configured signal duration must be a positive integer.

## Input and Output Interface

The design uses the following input and output signals:

| **Signal** | **Direction** | **Width** | **Function**                                    |
| ---------- | ------------- | --------- | ----------------------------------------------- |
| `clk`      | Input         | 1 bit     | Supplies the main FPGA clock                    |
| `rst`      | Input         | 1 bit     | Provides a synchronous, active-high reset       |
| `road_A`   | Output        | 3 bits    | Represents the traffic-light signals for Road A |
| `road_B`   | Output        | 3 bits    | Represents the traffic-light signals for Road B |

The three-bit road outputs follow the bit arrangement `{RED, YELLOW, GREEN}`.

The corresponding signal codes are:

* `3'b100` — Red light enabled
* `3'b010` — Yellow light enabled
* `3'b001` — Green light enabled

These output values use active-high logic, meaning that a logic value of `1` activates the associated light.

## Main Features

* **Moore FSM implementation:** Signal outputs are determined by the current state.
* **Clock division:** Converts the fast FPGA clock into a one-second timing reference.
* **Countdown timer:** Determines when each traffic-light phase ends.
* **Adjustable timing parameters:** Allows the clock frequency and signal durations to be customized.
* **All-red clearance phases:** Inserts an explicit interval between opposing traffic movements.
* **Default-safe output decoding:** Assigns red signals to both roads when an unrecognized state is encountered by the output logic.
* **Synchronous reset mechanism:** Initializes the controller to the A GREEN state.
* **Modular RTL organization:** Keeps timing control, state transitions, and signal decoding logically separated.

## Simulation and Verification

The RTL design can be tested using Verilog simulation tools such as Icarus Verilog, ModelSim, QuestaSim, or Vivado Simulator.

A dedicated testbench can be used to examine the reset sequence, state progression, signal durations, and output behavior. To reduce simulation time, the clock-frequency parameter can be set to a smaller value, such as 10 Hz, so that ten simulated clock cycles correspond to one second.

The following conditions are useful for verification:

1. The controller enters the A GREEN state after reset.
2. The FSM follows the specified sequence of six states.
3. Each phase remains active for its configured duration.
4. Road A and Road B are never green simultaneously.
5. The controller returns to A GREEN after completing a full cycle.
6. An invalid state produces the default all-red output pattern.

## Technologies and Design Concepts

* **Hardware description language:** Verilog HDL
* **Design approach:** Register Transfer Level (RTL)
* **Control architecture:** Moore Finite State Machine
* **Timing components:** Clock divider and countdown timer
* **Testing methodology:** Verilog testbench and RTL simulation
* **Implementation target:** FPGA, subject to synthesis, timing analysis, and hardware-specific configuration
