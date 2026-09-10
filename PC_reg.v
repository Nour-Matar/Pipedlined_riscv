module PC_reg(
    input         clk,
    input         areset,     
    input         en,          
    input         PCSrc,        
    input  [31:0] BranchTarget,
    output reg [31:0] PC
);

    always @(posedge clk or negedge areset) begin
        if (!areset)
            PC <= 32'b0;
        else if (PCSrc)
            PC <= BranchTarget; // Branch always overrides stall enable
        else if (en)
            PC <= PC + 32'd4;
    end

endmodule