# RV32I Single-Cycle & Pipelined RISC-V Processor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Verilog / SystemVerilog](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-blue)](https://en.wikipedia.org/wiki/Verilog)

A complete implementation of a 32-bit RISC-V (RV32I) processor designed in Verilog and SystemVerilog. This repository contains both single-cycle and 5-stage pipelined microarchitectures with hazard handling and forwarding units, prepared as part of the **IEEE CUSB Digital Design Workshop**.

---

## 📌 Architecture Overview

The core implements the base integer instruction set (RV32I) with a classic 5-stage pipeline layout:

1. **IF (Instruction Fetch):** Program Counter logic and Instruction Memory interface.
2. **ID (Instruction Decode):** Register File access, Control Unit, and Sign Extension.
3. **EX (Execute):** ALU operation, Branch Target calculation, and Branch Unit execution.
4. **MEM (Memory Access):** Data Memory read/write operations.
5. **WB (Write Back):** Result selection and register file writeback.

### Key Features
* **Full RV32I Support:** Implements Arithmetic, Logical, Memory (Load/Store), and Control Transfer (Branches/Jumps) instructions.
* **Hazard Management:**
  * **Forwarding Unit:** Resolves Data Hazards (EX->EX and MEM->EX forwarding) without inserting unnecessary stalls.
  * **Hazard Detection Unit:** Handles Load-Use dependencies by inserting pipeline bubbles (stalls) and flushing control lines.
* **Modular RTL Design:** Separated structural modules for clear testability and synthesis.

---

## 📁 Repository Structure

```text
.
├── ALU.v                    # Arithmetic Logic Unit
├── PC_reg.v                 # Program Counter Register
├── branch_unit.v            # Branch condition evaluation logic
├── control_unit.v           # Main Control Decoder
├── data_mem.v               # Data Memory module
├── instr_mem.v              # Instruction Memory (ROM/RAM)
├── register_file.v          # 32 x 32-bit Register File
├── sign_extend.v            # Immediate Extension Logic
├── MUX.v                    # Multiplexer blocks
├── forward_unit.v           # Data Forwarding Unit
├── hazard_detection_unit.sv # Hazard & Stall Detection Unit
├── if_id_reg.v              # Pipeline Register: IF -> ID
├── id_ex_reg.sv             # Pipeline Register: ID -> EX
├── ex_mem_reg.sv            # Pipeline Register: EX -> MEM
├── mem_wb_reg.sv            # Pipeline Register: MEM -> WB
├── pipelined_top.v          # Top-Level Pipelined Processor Core
├── pipelined_top_tb.sv      # SystemVerilog Testbench
├── final_project.pdf        # Full Design & Verification Report
└── README.md                # Project Documentation