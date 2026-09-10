vlib work
vlog ALU.v
vlog branch_unit.v
vlog control_unit.v
vlog data_mem.v
vlog ex_mem_reg.sv
vlog forward_unit.v
vlog hazard_detection_unit.sv
vlog id_ex_reg.sv
vlog if_id_reg.v
vlog instr_mem.v
vlog mem_wb_reg.sv
vlog MUX.v
vlog PC_reg.v
vlog register_file.v
vlog sign_extend.v
vlog pipelined_top.v
vlog pipelined_top_tb.sv
vsim -voptargs="+acc +cover" work.pipelined_top_tb
add wave *
run -all 


