module pipelined_top_tb;

    reg clk;
    reg rst;   // active-low async reset (matches pipelined_top.rst)

    pipelined_top dut (
        .clk (clk),
        .rst (rst)
    );

    // 100 MHz-ish clock
    initial clk = 1'b0;
    always #5 clk = ~clk;


    localparam IMEM_WORDS = 64;
    localparam DMEM_WORDS = 64;

    reg [31:0] iss_mem  [0:IMEM_WORDS-1];
    reg [31:0] iss_regs [0:31];
    reg [31:0] iss_dmem [0:DMEM_WORDS-1];

    logic [4:0]  reg_write_rd_q  [$];
    logic [31:0] reg_write_data_q[$];

    logic [31:0] mem_write_addr_q[$];
    logic [31:0] mem_write_data_q[$];

    task automatic run_iss();
        integer pc;
        integer steps;
        reg [31:0] instr;
        reg [6:0]  opcode;
        reg [4:0]  rd, rs1, rs2;
        reg [2:0]  funct3;
        reg [6:0]  funct7;
        reg [31:0] imm_i, imm_s, imm_b;
        reg [31:0] a, b, alu_out;
        reg        taken;
        reg        done;
        begin
            for (int i = 0; i < 32; i++) iss_regs[i] = 32'b0;
            for (int i = 0; i < DMEM_WORDS; i++) iss_dmem[i] = 32'b0;

            pc    = 0;
            steps = 0;
            done  = 1'b0;

            while (!done) begin
                instr = iss_mem[pc >> 2];
                steps = steps + 1;

                if (instr == 32'h0000_0000) begin
                    // matches DUT's Halt = (Instr_reg == 0)
                    done = 1'b1;
                end
                else if (steps > 10000) begin
                    $display("[ISS] step limit exceeded @PC=%0d - possible infinite loop, aborting golden model", pc);
                    done = 1'b1;
                end
                else begin
                    opcode = instr[6:0];
                    rd     = instr[11:7];
                    funct3 = instr[14:12];
                    rs1    = instr[19:15];
                    rs2    = instr[24:20];
                    funct7 = instr[31:25];

                    imm_i = {{20{instr[31]}}, instr[31:20]};
                    imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                    imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

                    a = (rs1 == 5'b0) ? 32'b0 : iss_regs[rs1];
                    b = (rs2 == 5'b0) ? 32'b0 : iss_regs[rs2];
                    taken = 1'b0;

                    case (opcode)
                        7'b0110011: begin // R-type
                            unique case ({funct7[5], funct3})
                                4'b0_000: alu_out = a + b;   // ADD
                                4'b1_000: alu_out = a - b;   // SUB
                                4'b0_001: alu_out = a << b;  // SLL
                                4'b0_100: alu_out = a ^ b;   // XOR
                                4'b0_101: alu_out = a >> b;  // SRL
                                4'b0_110: alu_out = a | b;   // OR
                                4'b0_111: alu_out = a & b;   // AND
                                default:  alu_out = 32'b0;
                            endcase
                            if (rd != 5'b0) begin
                                iss_regs[rd] = alu_out;
                                reg_write_rd_q.push_back(rd);
                                reg_write_data_q.push_back(alu_out);
                            end
                            pc = pc + 4;
                        end

                        7'b0010011: begin // I-type ALU
                            case (funct3)
                                3'b000: alu_out = a + imm_i;
                                3'b001: alu_out = a << imm_i[4:0];
                                3'b100: alu_out = a ^ imm_i;
                                3'b101: alu_out = a >> imm_i[4:0];
                                3'b110: alu_out = a | imm_i;
                                3'b111: alu_out = a & imm_i;
                                default: alu_out = 32'b0;
                            endcase
                            if (rd != 5'b0) begin
                                iss_regs[rd] = alu_out;
                                reg_write_rd_q.push_back(rd);
                                reg_write_data_q.push_back(alu_out);
                            end
                            pc = pc + 4;
                        end

                        7'b0000011: begin // LW
                            alu_out = a + imm_i;
                            if (rd != 5'b0) begin
                                iss_regs[rd] = iss_dmem[alu_out[31:2]];
                                reg_write_rd_q.push_back(rd);
                                reg_write_data_q.push_back(iss_dmem[alu_out[31:2]]);
                            end
                            pc = pc + 4;
                        end

                        7'b0100011: begin // SW
                            alu_out = a + imm_s;
                            iss_dmem[alu_out[31:2]] = b;
                            mem_write_addr_q.push_back(alu_out);
                            mem_write_data_q.push_back(b);
                            pc = pc + 4;
                        end

                        7'b1100011: begin // Branch (design always ALU-subtracts A-B)
                            case (funct3)
                                3'b000:  taken = (a == b);                 // BEQ (Zero)
                                3'b001:  taken = (a != b);                 // BNE (~Zero)
                                3'b100:  taken = $signed(a - b) < 0;       // BLT (sign of A-B)
                                default: taken = 1'b0;
                            endcase
                            pc = taken ? pc + $signed(imm_b) : pc + 4;
                        end

                        default: pc = pc + 4;
                    endcase
                end
            end
        end
    endtask


    integer checks_pass;
    integer checks_fail;

    task automatic check_reg_write(input [4:0] rd, input [31:0] data);
        reg [4:0]  exp_rd;
        reg [31:0] exp_data;
        begin
            if (reg_write_rd_q.size() == 0) begin
                $display("[%0t] FAIL: unexpected extra register write x%0d = 0x%08h (golden queue empty)",
                          $time, rd, data);
                checks_fail++;
            end else begin
                exp_rd   = reg_write_rd_q.pop_front();
                exp_data = reg_write_data_q.pop_front();
                if (exp_rd !== rd || exp_data !== data) begin
                    $display("[%0t] FAIL: register write mismatch. DUT: x%0d=0x%08h  Expected: x%0d=0x%08h",
                              $time, rd, data, exp_rd, exp_data);
                    checks_fail++;
                end else begin
                    $display("[%0t] PASS: register write x%0d = 0x%08h", $time, rd, data);
                    checks_pass++;
                end
            end
        end
    endtask

    task automatic check_mem_write(input [31:0] addr, input [31:0] data);
        reg [31:0] exp_addr;
        reg [31:0] exp_data;
        begin
            if (mem_write_addr_q.size() == 0) begin
                $display("[%0t] FAIL: unexpected extra memory write @0x%08h = 0x%08h (golden queue empty)",
                          $time, addr, data);
                checks_fail++;
            end else begin
                exp_addr = mem_write_addr_q.pop_front();
                exp_data = mem_write_data_q.pop_front();
                if (exp_addr !== addr || exp_data !== data) begin
                    $display("[%0t] FAIL: memory write mismatch. DUT: [0x%08h]=0x%08h  Expected: [0x%08h]=0x%08h",
                              $time, addr, data, exp_addr, exp_data);
                    checks_fail++;
                end else begin
                    $display("[%0t] PASS: memory write [0x%08h] = 0x%08h", $time, addr, data);
                    checks_pass++;
                end
            end
        end
    endtask

    // Sample commit points every cycle, offset slightly after the clock
    // edge so all pipeline register outputs have settled.
    always @(posedge clk) begin
        #1;
        if (rst === 1'b1) begin
            if (dut.RegWrite_WB && dut.Rd_WB != 5'b0)
                check_reg_write(dut.Rd_WB, dut.Result);
            if (dut.MemWrite_MEM)
                check_mem_write(dut.ALUResult_MEM, dut.WriteData_MEM);
        end
    end

    // ------------------------------------------------------------------
    // Halt detection & final architectural-state check
    // ------------------------------------------------------------------
    integer drain_cycles;
    integer timeout_cycles;

    task automatic final_state_check();
        integer i;
        integer mismatches;
        begin
            mismatches = 0;

            for (i = 1; i < 32; i++) begin // x0 is hard-wired, skip it
                if (dut.u_register_file.regs[i] !== iss_regs[i]) begin
                    $display("FAIL: final register x%0d = 0x%08h, expected 0x%08h",
                              i, dut.u_register_file.regs[i], iss_regs[i]);
                    mismatches++;
                end
            end

            for (i = 0; i < DMEM_WORDS; i++) begin
                if (dut.u_data_mem.mem[i] !== iss_dmem[i]) begin
                    $display("FAIL: final mem[%0d] = 0x%08h, expected 0x%08h",
                              i, dut.u_data_mem.mem[i], iss_dmem[i]);
                    mismatches++;
                end
            end

            if (mismatches == 0)
                $display("PASS: final register file and data memory match the golden model exactly.");
            else
                checks_fail += mismatches;
        end
    endtask

    // ------------------------------------------------------------------
    // Main test sequence
    // ------------------------------------------------------------------
    initial begin
        checks_pass = 0;
        checks_fail = 0;

        $readmemh("program.txt", iss_mem);
        run_iss();
        $display("[ISS] golden model finished: %0d register writes, %0d memory writes expected",
            reg_write_rd_q.size(), mem_write_addr_q.size());

        rst = 1'b0;   // assert active-low reset
        repeat (3) @(posedge clk);
        rst = 1'b1;   // release reset

        // Run until the DUT fetches the all-zero halt instruction, then
        // let the pipeline drain so the last few instructions retire.
        timeout_cycles = 0;
        while (dut.Instr_IF !== 32'h0000_0000 && timeout_cycles < 2000) begin
            @(posedge clk);
            timeout_cycles++;
        end

        if (timeout_cycles >= 2000) begin
            $display("FAIL: simulation timed out waiting for Halt (Instr_IF never fetched 0x00000000)");
            checks_fail++;
        end else begin
            // drain the 4 remaining pipeline stages
            repeat (8) @(posedge clk);
        end

        #2;
        final_state_check();

        $display("--------------------------------------------------");
        $display(" TESTBENCH SUMMARY: %0d passed, %0d failed", checks_pass, checks_fail);
        if (checks_fail == 0)
            $display(" RESULT: ALL CHECKS PASSED");
        else
            $display(" RESULT: FAILED - see log above");
        $display("--------------------------------------------------");

        $finish;
    end
endmodule
