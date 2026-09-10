module if_id_reg(
    input wire clk,
    input wire reset,
    input wire stall,     
    input wire flush,     
    input wire [31:0] Instr,
    input wire [31:0] PC,
    output reg [31:0] Instr_reg,
    output reg [31:0] PC_ID
);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            Instr_reg <= 32'b0;
            PC_ID     <= 32'b0;
        end
        else if (flush) begin
            Instr_reg <= 32'b0;
            PC_ID     <= 32'b0;
        end
        else if (!stall) begin
            Instr_reg <= Instr;
            PC_ID     <= PC;
        end
    end

endmodule