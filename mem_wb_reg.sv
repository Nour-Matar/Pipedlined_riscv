module MEM_WB_reg(
    input  wire        clk,
    input  wire        areset,
    input  wire        stall,
    input  wire        flush,

    input  wire [31:0] ALUResult_in,
    input  wire [31:0] ReadData_in,
    input  wire [4:0]  Rd_in,

    input  wire        RegWrite_in,
    input  wire        ResultSrc_in,

    output reg  [31:0] ALUResult_out,
    output reg  [31:0] ReadData_out,
    output reg  [4:0]  Rd_out,

    output reg          RegWrite_out,
    output reg          ResultSrc_out
);

    always @(posedge clk or negedge areset) begin
        if (!areset) begin
            ALUResult_out <= 32'b0;
            ReadData_out  <= 32'b0;
            Rd_out        <= 5'b0;
            RegWrite_out  <= 1'b0;
            ResultSrc_out <= 1'b0;
        end
        else if (flush) begin
            Rd_out        <= 5'b0;
            RegWrite_out  <= 1'b0;
            ResultSrc_out <= 1'b0;
        end
        else if (!stall) begin
            ALUResult_out <= ALUResult_in;
            ReadData_out  <= ReadData_in;
            Rd_out        <= Rd_in;
            RegWrite_out  <= RegWrite_in;
            ResultSrc_out <= ResultSrc_in;
        end
    end

endmodule