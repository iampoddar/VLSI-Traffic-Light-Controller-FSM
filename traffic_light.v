// ============================================================
// Project   : Traffic Light Controller (FSM)
// Author    : Prince Poddar
// College   : Dr B.C. Roy Engineering College, Durgapur
// Domain    : VLSI Design | Verilog HDL
// Description: Moore FSM with 4 states for a 2-way intersection
//              RED, GREEN, YELLOW, ALL_RED (safe transition)
// ============================================================

module traffic_light_fsm #(
    parameter integer CLOCK_FREQ_HZ = 50_000_000, // 50 MHz FPGA clock
    parameter integer GREEN_TIME    = 10,           // seconds
    parameter integer YELLOW_TIME   = 5,           // seconds
    parameter integer ALL_RED_TIME  = 10            // seconds
)(
    input  wire       clk,
    input  wire       rst,

    output reg [2:0] road_A, // {RED, YELLOW, GREEN}
    output reg [2:0] road_B  // {RED, YELLOW, GREEN}
);

    // Light definitions
    localparam [2:0] RED    = 3'b100;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] GREEN  = 3'b001;

    // State encoding
    localparam [2:0] S0_A_GREEN  = 3'b000;
    localparam [2:0] S1_A_YELLOW = 3'b001;
    localparam [2:0] S2_ALL_RED1 = 3'b010;
    localparam [2:0] S3_B_GREEN  = 3'b011;
    localparam [2:0] S4_B_YELLOW = 3'b100;
    localparam [2:0] S5_ALL_RED2 = 3'b101;

    reg [2:0] state;
    reg [2:0] next_state;

    // Clock divider 
    localparam integer CLK_COUNT_WIDTH =
                    (CLOCK_FREQ_HZ <= 1) ? 1 : $clog2(CLOCK_FREQ_HZ);

    reg [CLK_COUNT_WIDTH-1:0] clk_count;
    reg                       one_sec_tick;

    always @(posedge clk) begin
        if (rst) begin
            clk_count    <= 0;
            one_sec_tick <= 1'b0;
        end
        else begin
            if (clk_count == CLOCK_FREQ_HZ - 1) begin
                clk_count    <= 0;
                one_sec_tick <= 1'b1;
            end
            else begin
                clk_count    <= clk_count + 1'b1;
                one_sec_tick <= 1'b0;
            end
        end
    end

    // Timer
    reg [31:0] timer;

    always @(posedge clk) begin
        if (rst) begin
            state <= S0_A_GREEN;
            timer <= GREEN_TIME - 1;
        end
        else if (one_sec_tick) begin

            if (timer == 0) begin

                // Move to next state
                state <= next_state;

                // Load timer according to new state
                case (next_state)

                    S0_A_GREEN,
                    S3_B_GREEN:
                        timer <= GREEN_TIME - 1;

                    S1_A_YELLOW,
                    S4_B_YELLOW:
                        timer <= YELLOW_TIME - 1;

                    S2_ALL_RED1,
                    S5_ALL_RED2:
                        timer <= ALL_RED_TIME - 1;

                    default:
                        timer <= GREEN_TIME - 1;

                endcase

            end
            else begin
                timer <= timer - 1;
            end
        end
    end

    // Next-state logic
    always @(*) begin

        // Safe default
        next_state = S0_A_GREEN;

        case (state)

            S0_A_GREEN:
                next_state = S1_A_YELLOW;

            S1_A_YELLOW:
                next_state = S2_ALL_RED1;

            S2_ALL_RED1:
                next_state = S3_B_GREEN;

            S3_B_GREEN:
                next_state = S4_B_YELLOW;

            S4_B_YELLOW:
                next_state = S5_ALL_RED2;

            S5_ALL_RED2:
                next_state = S0_A_GREEN;

            default:
                next_state = S0_A_GREEN;

        endcase
    end

    // Moore output logic
    always @(*) begin

        // Safe default: both roads RED
        road_A = RED;
        road_B = RED;

        case (state)

            // Road A GREEN, Road B RED
            S0_A_GREEN: begin
                road_A = GREEN;
                road_B = RED;
            end

            // Road A YELLOW, Road B RED
            S1_A_YELLOW: begin
                road_A = YELLOW;
                road_B = RED;
            end

            // Both RED
            S2_ALL_RED1: begin
                road_A = RED;
                road_B = RED;
            end

            // Road A RED, Road B GREEN
            S3_B_GREEN: begin
                road_A = RED;
                road_B = GREEN;
            end

            // Road A RED, Road B YELLOW
            S4_B_YELLOW: begin
                road_A = RED;
                road_B = YELLOW;
            end

            // Both RED
            S5_ALL_RED2: begin
                road_A = RED;
                road_B = RED;
            end

            // Invalid state -> safe condition
            default: begin	
                road_A = RED;
                road_B = RED;
            end

        endcase
    end

endmodule