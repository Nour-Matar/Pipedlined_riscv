module register_file (
    input  wire        clk,
    input  wire        reset,      
    input  wire [4:0]  A1,
    input  wire [4:0]  A2,
    input  wire [4:0]  A3,
    input  wire [31:0] WD3,
    input  wire        WE3,
    output wire [31:0] RD1,
    output wire [31:0] RD2
);

    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (WE3 && (A3 != 5'b00000)) begin
            regs[A3] <= WD3;
        end
    end

    // Asynchronous reads with internal write-to-read forwarding
    assign RD1 = (A1 == 5'b00000) ? 32'b0 :
                 (WE3 && (A3 == A1)) ? WD3 :
                 regs[A1];

    assign RD2 = (A2 == 5'b00000) ? 32'b0 :
                 (WE3 && (A3 == A2)) ? WD3 :
                 regs[A2];

endmodule