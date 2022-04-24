module toplevel(
	input Clk, rst, validi,
	 input [7:0] data_in,
	output valido,
	output [7:0] data_out
);

logic [2:0] alu1_op=3'b111, alu2_op=3'b000;
logic [7:0] alu1_out, alu2_out, alu2_in, temp_out;

alu mult(
        .Clk(Clk),
        .A(temp_out),
        .B(data_in),
	.Op(alu1_op),
	.R(alu1_out)
);

alu add(
	.Clk(Clk),
        .A(alu2_in),
        .B(data_in),
        .Op(alu2_op),
        .R(alu2_out)
);

ex1_1 fsm(
        .clk(Clk),
        .rst(rst),
        .validi(validi),
        .valido(valido),
        .data_in(data_in),
        .data_out(temp_out)
);


assign alu2_in=alu1_out;
assign data_out= (valido) ? data_out: alu2_out;

endmodule:toplevel
	

	
