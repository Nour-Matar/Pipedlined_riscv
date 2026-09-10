module data_mem(
    input wire clk,
    input wire [31:0] A,
    input wire [31:0] WD,
    input wire WE,
    output wire [31:0] RD
);

    reg [31:0] mem [0:63];
    integer i;
    initial begin
        for(i=0; i<64; i=i+1)
            mem[i]= 32'b0;
    end
    
    always @(posedge clk) begin
        if(WE)
            mem[A[31:2]] <= WD;
    end

    assign RD = mem[A[31:2]];
endmodule
