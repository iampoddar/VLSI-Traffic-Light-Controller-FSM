# VLSI-Traffic-Light-FSM
This project implements a two-road traffic light controller using Verilog HDL and a Moore Finite State Machine (FSM). The controller manages the traffic signals for two intersecting roads, Road A and Road B, by cycling through green, yellow, and red light combinations in a predefined sequence.

The design uses a clock divider to generate a one-second timing pulse from the FPGA's high-frequency clock. A countdown timer uses this pulse to control the duration of each traffic-light state. The controller also incorporates dedicated all-red states between the traffic phases to provide a clearance interval before traffic is permitted to move in the opposite direction.

The project demonstrates the practical application of digital design concepts, including finite state machines, sequential and combinational logic, clock division, countdown timers, parameterization, and RTL design using Verilog HDL.
