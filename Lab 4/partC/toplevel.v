module toplevel(
	input Clk, rst, validi,
	 input [7:0] data_in,
	output valido,
	output [7:0] data_out
);
logic [2:0] add_op = 3'b000, mult_op=3'b111;
logic [7:0] mult_out, add_out, add_in, temp_out;

alu mult(
        .Clk(Clk),
        .A(temp_out),
        .B(data_in),
	.Op(mult_op), //multiplication
	.R(mult_out)
);

alu add(
	.Clk(Clk),
        .A(add_in),
        .B(data_in),
        .Op(add_op), //addition
        .R(add_out)
);

ex1_1 fsm(
        .clk(Clk),
        .rst(rst),
        .validi(validi),
        .valido(valido),
        .data_in(data_in),
        .data_out(temp_out)
);


assign add_in=mult_out;
assign data_out= (valido) ? data_out: add_out;

endmodule:toplevel
	

	
