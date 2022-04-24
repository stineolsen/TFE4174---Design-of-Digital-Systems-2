timeunit 10ns; 
`include "alu_packet.sv"
//`include "alu_assertions.sv"

module alu_tb();
	reg clk = 0;
	bit [0:7] a = 8'h0;
	bit [0:7] b = 8'h0;
	bit [0:2] op = 3'h0;
	wire [0:7] r;

parameter NUMBERS = 10000;

//make your vector here

alu_data test_data[NUMBERS];

//Make your loop here
initial begin: data_gen
int i;
#20; //delay of 20 before loop 

for ( i= 0; i<NUMBERS; i++) begin 
	test_data[i]=new();
	test_data[i].randomize();
	test_data[i].get(a,b,op);
#20; //delay of 20 inside the loop
end
end: data_gen 

//Displaying signals on the screen
always @(posedge clk) 
  $display($stime,,,"clk=%b a=%b b=%b op=%b r=%b",clk,a,b,op,r);

//Clock generation
always #10 clk=~clk;

//Declaration of the VHDL alu
alu dut (clk,a,b,op,r);

//Make your opcode enumeration here
typedef enum {ADD,SUB,MULT,NOT,NAND,NOR,AND,OR} opcode;

//Make your covergroup here
covergroup alu_cg @(posedge clk);
	op_c: coverpoint op;
	a_c: coverpoint a{
		bins zero ={0};
		bins small_ ={[1:50]};
		bins hunds[]={100,200};
		bins large_ ={[200:$]};
		bins others=default;
	}
	ab_c: cross a,b;
endgroup

//Initialize your covergroup here
initial begin
alu_cg cg_inst= new(); 
end
//Sample covergroup here
//done by declaring fixed sampling edge by adding  @(posedge clk) 

endmodule:alu_tb
