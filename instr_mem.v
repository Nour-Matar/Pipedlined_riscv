module instr_mem(
    input wire [31:0] A,
    output wire [31:0] Instr
);

    reg [31:0] mem [0:63];
    integer i;
    initial begin
        for(i=0; i<64; i=i+1)
            mem[i]= 32'b0;
        $readmemh("program.txt", mem);
    end

    assign Instr= mem[A[31:2]];
endmodule