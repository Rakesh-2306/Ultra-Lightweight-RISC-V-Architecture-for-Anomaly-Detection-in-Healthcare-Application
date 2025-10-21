/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-2
// Date      : Mon Sep 22 18:51:34 2025
/////////////////////////////////////////////////////////////


module riscv_id ( if_pc, if_instr, if_valid, rs1_data, rs2_data, imm_out, 
        rd_out, rs1_out, rs2_out, alu_op_out, alu_src_imm_out, is_load_out, 
        is_store_out, reg_write_out, wb_sel_out, is_branch_out, branch_imm_out
 );
  input [31:0] if_pc;
  input [31:0] if_instr;
  input [31:0] rs1_data;
  input [31:0] rs2_data;
  output [31:0] imm_out;
  output [4:0] rd_out;
  output [31:0] rs1_out;
  output [31:0] rs2_out;
  output [3:0] alu_op_out;
  output [1:0] wb_sel_out;
  output [31:0] branch_imm_out;
  input if_valid;
  output alu_src_imm_out, is_load_out, is_store_out, reg_write_out,
         is_branch_out;
  wire   if_instr_6, if_instr_5, if_instr_4, if_instr_3, if_instr_2,
         if_instr_1, if_instr_0, \wb_sel_out[0] , n82, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81;
  assign branch_imm_out[0] = 1'b0;
  assign wb_sel_out[1] = 1'b0;
  assign if_instr_6 = if_instr[6];
  assign if_instr_5 = if_instr[5];
  assign if_instr_4 = if_instr[4];
  assign if_instr_3 = if_instr[3];
  assign if_instr_2 = if_instr[2];
  assign if_instr_1 = if_instr[1];
  assign if_instr_0 = if_instr[0];
  assign imm_out[20] = imm_out[31];
  assign imm_out[21] = imm_out[31];
  assign imm_out[22] = imm_out[31];
  assign imm_out[23] = imm_out[31];
  assign imm_out[24] = imm_out[31];
  assign imm_out[25] = imm_out[31];
  assign imm_out[26] = imm_out[31];
  assign imm_out[27] = imm_out[31];
  assign imm_out[28] = imm_out[31];
  assign imm_out[29] = imm_out[31];
  assign imm_out[30] = imm_out[31];
  assign rd_out[4] = if_instr[11];
  assign rd_out[3] = if_instr[10];
  assign rd_out[2] = if_instr[9];
  assign rd_out[1] = if_instr[8];
  assign rd_out[0] = if_instr[7];
  assign rs1_out[31] = rs1_data[31];
  assign rs1_out[30] = rs1_data[30];
  assign rs1_out[29] = rs1_data[29];
  assign rs1_out[28] = rs1_data[28];
  assign rs1_out[27] = rs1_data[27];
  assign rs1_out[26] = rs1_data[26];
  assign rs1_out[25] = rs1_data[25];
  assign rs1_out[24] = rs1_data[24];
  assign rs1_out[23] = rs1_data[23];
  assign rs1_out[22] = rs1_data[22];
  assign rs1_out[21] = rs1_data[21];
  assign rs1_out[20] = rs1_data[20];
  assign rs1_out[19] = rs1_data[19];
  assign rs1_out[18] = rs1_data[18];
  assign rs1_out[17] = rs1_data[17];
  assign rs1_out[16] = rs1_data[16];
  assign rs1_out[15] = rs1_data[15];
  assign rs1_out[14] = rs1_data[14];
  assign rs1_out[13] = rs1_data[13];
  assign rs1_out[12] = rs1_data[12];
  assign rs1_out[11] = rs1_data[11];
  assign rs1_out[10] = rs1_data[10];
  assign rs1_out[9] = rs1_data[9];
  assign rs1_out[8] = rs1_data[8];
  assign rs1_out[7] = rs1_data[7];
  assign rs1_out[6] = rs1_data[6];
  assign rs1_out[5] = rs1_data[5];
  assign rs1_out[4] = rs1_data[4];
  assign rs1_out[3] = rs1_data[3];
  assign rs1_out[2] = rs1_data[2];
  assign rs1_out[1] = rs1_data[1];
  assign rs1_out[0] = rs1_data[0];
  assign rs2_out[31] = rs2_data[31];
  assign rs2_out[30] = rs2_data[30];
  assign rs2_out[29] = rs2_data[29];
  assign rs2_out[28] = rs2_data[28];
  assign rs2_out[27] = rs2_data[27];
  assign rs2_out[26] = rs2_data[26];
  assign rs2_out[25] = rs2_data[25];
  assign rs2_out[24] = rs2_data[24];
  assign rs2_out[23] = rs2_data[23];
  assign rs2_out[22] = rs2_data[22];
  assign rs2_out[21] = rs2_data[21];
  assign rs2_out[20] = rs2_data[20];
  assign rs2_out[19] = rs2_data[19];
  assign rs2_out[18] = rs2_data[18];
  assign rs2_out[17] = rs2_data[17];
  assign rs2_out[16] = rs2_data[16];
  assign rs2_out[15] = rs2_data[15];
  assign rs2_out[14] = rs2_data[14];
  assign rs2_out[13] = rs2_data[13];
  assign rs2_out[12] = rs2_data[12];
  assign rs2_out[11] = rs2_data[11];
  assign rs2_out[10] = rs2_data[10];
  assign rs2_out[9] = rs2_data[9];
  assign rs2_out[8] = rs2_data[8];
  assign rs2_out[7] = rs2_data[7];
  assign rs2_out[6] = rs2_data[6];
  assign rs2_out[5] = rs2_data[5];
  assign rs2_out[4] = rs2_data[4];
  assign rs2_out[3] = rs2_data[3];
  assign rs2_out[2] = rs2_data[2];
  assign rs2_out[1] = rs2_data[1];
  assign rs2_out[0] = rs2_data[0];
  assign wb_sel_out[0] = \wb_sel_out[0] ;
  assign is_load_out = \wb_sel_out[0] ;
  assign branch_imm_out[12] = branch_imm_out[31];
  assign branch_imm_out[13] = branch_imm_out[31];
  assign branch_imm_out[14] = branch_imm_out[31];
  assign branch_imm_out[15] = branch_imm_out[31];
  assign branch_imm_out[16] = branch_imm_out[31];
  assign branch_imm_out[17] = branch_imm_out[31];
  assign branch_imm_out[18] = branch_imm_out[31];
  assign branch_imm_out[19] = branch_imm_out[31];
  assign branch_imm_out[20] = branch_imm_out[31];
  assign branch_imm_out[21] = branch_imm_out[31];
  assign branch_imm_out[22] = branch_imm_out[31];
  assign branch_imm_out[23] = branch_imm_out[31];
  assign branch_imm_out[24] = branch_imm_out[31];
  assign branch_imm_out[25] = branch_imm_out[31];
  assign branch_imm_out[26] = branch_imm_out[31];
  assign branch_imm_out[27] = branch_imm_out[31];
  assign branch_imm_out[28] = branch_imm_out[31];
  assign branch_imm_out[29] = branch_imm_out[31];
  assign branch_imm_out[30] = branch_imm_out[31];

  INVX0_HVT U84 ( .A(n80), .Y(n77) );
  INVX0_HVT U85 ( .A(n75), .Y(n48) );
  INVX0_HVT U86 ( .A(n66), .Y(n60) );
  INVX0_HVT U87 ( .A(alu_op_out[3]), .Y(n54) );
  INVX0_HVT U88 ( .A(n68), .Y(is_branch_out) );
  INVX0_HVT U89 ( .A(n78), .Y(n79) );
  INVX0_HVT U90 ( .A(n82), .Y(n68) );
  INVX0_HVT U91 ( .A(n56), .Y(n61) );
  INVX0_HVT U92 ( .A(n42), .Y(n43) );
  INVX0_HVT U93 ( .A(if_instr[30]), .Y(n41) );
  INVX0_HVT U94 ( .A(if_instr[13]), .Y(n63) );
  INVX0_HVT U95 ( .A(if_instr_3), .Y(n45) );
  INVX0_HVT U96 ( .A(if_instr[25]), .Y(n49) );
  INVX0_HVT U97 ( .A(if_instr[12]), .Y(n58) );
  INVX0_HVT U98 ( .A(if_instr_4), .Y(n70) );
  INVX0_HVT U99 ( .A(if_instr_5), .Y(n55) );
  AND2X1_HVT U100 ( .A1(is_branch_out), .A2(rd_out[0]), .Y(branch_imm_out[11])
         );
  AND2X1_HVT U101 ( .A1(is_branch_out), .A2(if_instr[30]), .Y(
        branch_imm_out[10]) );
  AND2X1_HVT U102 ( .A1(is_branch_out), .A2(if_instr[29]), .Y(
        branch_imm_out[9]) );
  AND2X1_HVT U103 ( .A1(is_branch_out), .A2(if_instr[28]), .Y(
        branch_imm_out[8]) );
  AND2X1_HVT U104 ( .A1(is_branch_out), .A2(if_instr[27]), .Y(
        branch_imm_out[7]) );
  AND2X1_HVT U105 ( .A1(is_branch_out), .A2(if_instr[26]), .Y(
        branch_imm_out[6]) );
  AND2X1_HVT U106 ( .A1(n82), .A2(if_instr[25]), .Y(branch_imm_out[5]) );
  AND2X1_HVT U107 ( .A1(n82), .A2(rd_out[4]), .Y(branch_imm_out[4]) );
  AND2X1_HVT U108 ( .A1(n82), .A2(rd_out[3]), .Y(branch_imm_out[3]) );
  AND2X1_HVT U109 ( .A1(n82), .A2(rd_out[2]), .Y(branch_imm_out[2]) );
  AND2X1_HVT U110 ( .A1(n82), .A2(rd_out[1]), .Y(branch_imm_out[1]) );
  AND2X2_HVT U111 ( .A1(n82), .A2(if_instr[31]), .Y(branch_imm_out[31]) );
  NAND2X0_HVT U112 ( .A1(if_instr_0), .A2(if_instr_1), .Y(n73) );
  NOR4X0_HVT U113 ( .A1(if_instr_6), .A2(if_instr_2), .A3(if_instr_3), .A4(n73), .Y(n64) );
  OA21X1_HVT U114 ( .A1(n55), .A2(n70), .A3(n64), .Y(alu_src_imm_out) );
  OR3X1_HVT U115 ( .A1(if_instr[26]), .A2(if_instr[31]), .A3(if_instr[29]), 
        .Y(n40) );
  NOR3X0_HVT U116 ( .A1(if_instr[28]), .A2(if_instr[27]), .A3(n40), .Y(n50) );
  AND3X1_HVT U117 ( .A1(if_instr[25]), .A2(n50), .A3(n41), .Y(n57) );
  AND4X1_HVT U118 ( .A1(if_instr_5), .A2(if_instr_4), .A3(n57), .A4(n64), .Y(
        alu_op_out[3]) );
  NAND3X0_HVT U119 ( .A1(if_instr_5), .A2(if_instr_6), .A3(n70), .Y(n42) );
  NOR4X0_HVT U120 ( .A1(if_instr_3), .A2(if_instr_2), .A3(n73), .A4(n42), .Y(
        n82) );
  AND4X1_HVT U121 ( .A1(if_instr_0), .A2(if_instr_1), .A3(if_instr_2), .A4(n43), .Y(n44) );
  OR2X1_HVT U122 ( .A1(n44), .A2(alu_src_imm_out), .Y(n81) );
  AND2X1_HVT U123 ( .A1(if_instr[31]), .A2(n81), .Y(imm_out[31]) );
  NAND2X0_HVT U124 ( .A1(if_instr_3), .A2(n44), .Y(n75) );
  AND2X1_HVT U125 ( .A1(if_instr[31]), .A2(n45), .Y(n46) );
  AND2X1_HVT U126 ( .A1(n46), .A2(n81), .Y(n47) );
  AO21X1_HVT U127 ( .A1(n48), .A2(if_instr[19]), .A3(n47), .Y(imm_out[19]) );
  AO21X1_HVT U128 ( .A1(n48), .A2(if_instr[18]), .A3(n47), .Y(imm_out[18]) );
  AO21X1_HVT U129 ( .A1(n48), .A2(if_instr[17]), .A3(n47), .Y(imm_out[17]) );
  AO21X1_HVT U130 ( .A1(n48), .A2(if_instr[16]), .A3(n47), .Y(imm_out[16]) );
  AO21X1_HVT U131 ( .A1(n48), .A2(if_instr[15]), .A3(n47), .Y(imm_out[15]) );
  AO21X1_HVT U132 ( .A1(n48), .A2(if_instr[14]), .A3(n47), .Y(imm_out[14]) );
  AO21X1_HVT U133 ( .A1(n48), .A2(if_instr[13]), .A3(n47), .Y(imm_out[13]) );
  AO21X1_HVT U134 ( .A1(n48), .A2(if_instr[12]), .A3(n47), .Y(imm_out[12]) );
  AO21X1_HVT U135 ( .A1(if_instr[20]), .A2(n48), .A3(n47), .Y(imm_out[11]) );
  NAND3X0_HVT U136 ( .A1(if_instr_4), .A2(if_instr[14]), .A3(n64), .Y(n56) );
  NAND3X0_HVT U137 ( .A1(if_instr_5), .A2(if_instr_4), .A3(n64), .Y(n76) );
  NAND3X0_HVT U138 ( .A1(if_instr[30]), .A2(n50), .A3(n49), .Y(n51) );
  OR3X1_HVT U139 ( .A1(if_instr[13]), .A2(n76), .A3(n51), .Y(n67) );
  NAND2X0_HVT U140 ( .A1(n56), .A2(n67), .Y(n52) );
  NAND2X0_HVT U141 ( .A1(n58), .A2(n52), .Y(n53) );
  NAND3X0_HVT U142 ( .A1(n54), .A2(n68), .A3(n53), .Y(alu_op_out[1]) );
  AND3X1_HVT U143 ( .A1(if_instr_5), .A2(n64), .A3(n70), .Y(is_store_out) );
  AND3X1_HVT U144 ( .A1(n64), .A2(n55), .A3(n70), .Y(\wb_sel_out[0] ) );
  AND2X1_HVT U145 ( .A1(if_instr_5), .A2(n57), .Y(n66) );
  NAND2X0_HVT U146 ( .A1(if_instr[13]), .A2(n58), .Y(n59) );
  NAND3X0_HVT U147 ( .A1(n61), .A2(n60), .A3(n59), .Y(n62) );
  NAND2X0_HVT U148 ( .A1(n68), .A2(n62), .Y(alu_op_out[0]) );
  NAND4X0_HVT U149 ( .A1(n64), .A2(if_instr_4), .A3(if_instr[12]), .A4(n63), 
        .Y(n65) );
  OA22X1_HVT U150 ( .A1(if_instr[14]), .A2(n67), .A3(n66), .A4(n65), .Y(n69)
         );
  NAND2X0_HVT U151 ( .A1(n69), .A2(n68), .Y(alu_op_out[2]) );
  OR3X1_HVT U152 ( .A1(if_instr_6), .A2(if_instr_2), .A3(if_instr_3), .Y(n72)
         );
  NAND4X0_HVT U153 ( .A1(if_instr_2), .A2(if_instr_6), .A3(if_instr_5), .A4(
        n70), .Y(n71) );
  OA22X1_HVT U154 ( .A1(if_instr_5), .A2(n72), .A3(if_instr_3), .A4(n71), .Y(
        n74) );
  OR2X1_HVT U155 ( .A1(n74), .A2(n73), .Y(n78) );
  NAND2X0_HVT U156 ( .A1(n75), .A2(n78), .Y(n80) );
  NAND2X0_HVT U157 ( .A1(n77), .A2(n76), .Y(reg_write_out) );
  AO22X1_HVT U158 ( .A1(n79), .A2(if_instr[20]), .A3(is_store_out), .A4(
        rd_out[0]), .Y(imm_out[0]) );
  AO22X1_HVT U159 ( .A1(is_store_out), .A2(rd_out[1]), .A3(if_instr[21]), .A4(
        n80), .Y(imm_out[1]) );
  AO22X1_HVT U160 ( .A1(rd_out[2]), .A2(is_store_out), .A3(if_instr[22]), .A4(
        n80), .Y(imm_out[2]) );
  AO22X1_HVT U161 ( .A1(rd_out[3]), .A2(is_store_out), .A3(if_instr[23]), .A4(
        n80), .Y(imm_out[3]) );
  AO22X1_HVT U162 ( .A1(rd_out[4]), .A2(is_store_out), .A3(if_instr[24]), .A4(
        n80), .Y(imm_out[4]) );
  AND2X1_HVT U163 ( .A1(if_instr[25]), .A2(n81), .Y(imm_out[5]) );
  AND2X1_HVT U164 ( .A1(if_instr[26]), .A2(n81), .Y(imm_out[6]) );
  AND2X1_HVT U165 ( .A1(if_instr[27]), .A2(n81), .Y(imm_out[7]) );
  AND2X1_HVT U166 ( .A1(if_instr[28]), .A2(n81), .Y(imm_out[8]) );
  AND2X1_HVT U167 ( .A1(if_instr[29]), .A2(n81), .Y(imm_out[9]) );
  AND2X1_HVT U168 ( .A1(if_instr[30]), .A2(n81), .Y(imm_out[10]) );
endmodule

