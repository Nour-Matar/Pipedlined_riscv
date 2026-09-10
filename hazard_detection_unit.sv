module hazard_detection_unit (
    input  wire       ResultSrc_EX,
    input  wire [4:0] Rd_EX,
    input  wire [4:0] Rs1_ID,
    input  wire [4:0] Rs2_ID,
    output wire       lwStall
);

    // Stall if EX stage is a Load instruction and ID stage source registers match Rd_EX
    assign lwStall = ResultSrc_EX && (Rd_EX != 5'b00000) && 
                     ((Rd_EX == Rs1_ID) || (Rd_EX == Rs2_ID));

endmodule