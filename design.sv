module imem(input [7:0] addr, output [15:0] instr);
  reg [15:0] memory [0:255];
  initial begin
    memory[0] = 16'b0001_0001_0010_0011; // ADD R1 = R2 + R3
    memory[1] = 16'b0010_0100_0101_0101; // SUB R4 = R5 - R5
    memory[2] = 16'b1111_0000_0000_0000; // HALT
  end
  assign instr = memory[addr];
endmodule

module regfile(input clk, input we, input [3:0] ra1, ra2, wa,
               input [7:0] wd, output [7:0] rd1, rd2);
  reg [7:0] regs [0:15];
  always @(posedge clk) begin
    if (we) regs[wa] <= wd;
  end
  assign rd1 = regs[ra1];
  assign rd2 = regs[ra2];
endmodule

module alu(input [7:0] a, b, input [1:0] op, output reg [7:0] result);
  always @(*) begin
    case(op)
      2'b00: result = a + b;   // ADD
      2'b01: result = a - b;   // SUB
      2'b10: result = a & b;   // AND
      2'b11: result = a | b;   // OR
    endcase
  end
endmodule

module control(input [3:0] opcode, output reg [1:0] alu_op, output reg reg_write);
  always @(*) begin
    case(opcode)
      4'b0001: begin alu_op = 2'b00; reg_write = 1; end // ADD
      4'b0010: begin alu_op = 2'b01; reg_write = 1; end // SUB
      4'b0011: begin alu_op = 2'b10; reg_write = 1; end // AND
      4'b0100: begin alu_op = 2'b11; reg_write = 1; end // OR
      default: begin alu_op = 2'b00; reg_write = 0; end // NOP/HALT
    endcase
  end
endmodule

module cpu(input clk, input rst);
  reg [7:0] pc = 0;
  wire [15:0] instr;
  wire [3:0] opcode, rd, rs1, rs2;
  wire [7:0] a, b, result;
  wire [1:0] alu_op;
  wire reg_write;

  assign opcode = instr[15:12];
  assign rd     = instr[11:8];
  assign rs1    = instr[7:4];
  assign rs2    = instr[3:0];

  imem im(pc, instr);
  regfile rf(clk, reg_write, rs1, rs2, rd, result, a, b);
  alu alu1(a, b, alu_op, result);
  control cu(opcode, alu_op, reg_write);

  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 0;
    else if (opcode != 4'b1111) pc <= pc + 1; // skip HALT
  end
endmodule
