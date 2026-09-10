module forward_unit (
    input  wire [4:0] Rs1_EX,
    input  wire [4:0] Rs2_EX,
    input  wire [4:0] Rd_MEM,
    input  wire       RegWrite_MEM,
    input  wire [4:0] Rd_WB,
    input  wire       RegWrite_WB,
    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB
);

    always @(*) begin
        // Forwarding logic for Operand A (rs1)
        if (RegWrite_MEM && (Rd_MEM != 5'b00000) && (Rd_MEM == Rs1_EX))
            ForwardA = 2'b10; // Forward from MEM stage
        else if (RegWrite_WB && (Rd_WB != 5'b00000) && (Rd_WB == Rs1_EX))
            ForwardA = 2'b01; // Forward from WB stage
        else
            ForwardA = 2'b00; // Use RD1_EX

        // Forwarding logic for Operand B (rs2)
        if (RegWrite_MEM && (Rd_MEM != 5'b00000) && (Rd_MEM == Rs2_EX))
            ForwardB = 2'b10; // Forward from MEM stage
        else if (RegWrite_WB && (Rd_WB != 5'b00000) && (Rd_WB == Rs2_EX))
            ForwardB = 2'b01; // Forward from WB stage
        else
            ForwardB = 2'b00; // Use RD2_EX
    end

endmodule