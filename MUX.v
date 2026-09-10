module mux(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire S0,
    output wire [31:0] Z
);

    assign Z = (S0 == 1'b0) ? A : B;

endmodule
