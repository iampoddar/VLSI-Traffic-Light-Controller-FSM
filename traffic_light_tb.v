
`timescale 1ns/1ps

module tb_traffic_light_fsm;

    //========================================================
    // Simulation parameters
    //========================================================
    localparam integer CLOCK_FREQ_HZ = 10;
    localparam integer GREEN_TIME   = 5;
    localparam integer YELLOW_TIME  = 2;
    localparam integer ALL_RED_TIME = 1;

    //========================================================
    // Signals
    //========================================================
    reg clk;
    reg rst;

    wire [2:0] road_A;
    wire [2:0] road_B;

    //========================================================
    // Light definitions
    //========================================================
    localparam [2:0] RED    = 3'b100;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] GREEN  = 3'b001;

    //========================================================
    // DUT
    //========================================================
    traffic_light_fsm #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME),
        .ALL_RED_TIME(ALL_RED_TIME)
    ) dut (
        .clk(clk),
        .rst(rst),
        .road_A(road_A),
        .road_B(road_B)
    );

    //========================================================
    // Clock
    //========================================================
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    //========================================================
    // Monitor outputs
    //========================================================
    always @(road_A or road_B) begin

        $display(
            "Time=%0t ns | Road A=%b | Road B=%b",
            $time,
            road_A,
            road_B
        );

        // Both roads must never be GREEN
        if ((road_A == GREEN) && (road_B == GREEN)) begin
            $display("ERROR: Both roads are GREEN!");
            $fatal;
        end

        // Road A GREEN -> B must be RED
        if (road_A == GREEN && road_B != RED) begin
            $display("ERROR: A GREEN but B is not RED!");
            $fatal;
        end

        // Road B GREEN -> A must be RED
        if (road_B == GREEN && road_A != RED) begin
            $display("ERROR: B GREEN but A is not RED!");
            $fatal;
        end

        // Road A YELLOW -> B must be RED
        if (road_A == YELLOW && road_B != RED) begin
            $display("ERROR: A YELLOW but B is not RED!");
            $fatal;
        end

        // Road B YELLOW -> A must be RED
        if (road_B == YELLOW && road_A != RED) begin
            $display("ERROR: B YELLOW but A is not RED!");
            $fatal;
        end

    end

    //========================================================
    // Main test
    //========================================================
    initial begin

        $display("");
        $display("======================================");
        $display(" Traffic Light FSM Simulation");
        $display("======================================");

        // Reset
        rst = 1;

        repeat (2)
            @(posedge clk);

        #1;

        // Check reset behavior
        if ((road_A !== GREEN) || (road_B !== RED)) begin
            $display("ERROR: Reset state is incorrect!");
            $fatal;
        end

        $display("Reset test PASSED");

        // Release reset
        rst = 0;

        // Run for enough time to see
        // multiple complete cycles.
        repeat (160)
            @(posedge clk);

        $display("");
        $display("======================================");
        $display(" SIMULATION COMPLETED");
        $display(" ALL SAFETY CHECKS PASSED");
        $display("======================================");

        $finish;

    end

endmodule