/*
 * ex1_1
 * 
 * Purpose:
 * - Reset on rst=1
 * - When validi=1 three clk's in a row, compute data_out=a*b+c
 *   where a is data_in on the first clk, b on the second and c
 *   on the third. Also set valido=1. Else valido=0 which means
 *   data_out is not valid.
 */

module ex1_1 (
	      input 		  clk, rst, validi,
	      input [31:0] 	  data_in,
	      output logic 	  valido, 
	      output logic [31:0] data_out
	      );
   
   enum 			  {S0, S1, S2, S3} state = S0, next = S0;
   
   logic [31:0] 		  a, b, alu1_out, alu2_out, data_in_temp, alu1_in, alu2_in, alu_out;
   logic [2:0] 			  Op;
   logic temp_clk;



alu init (
        .Clk(clk),
        .A(alu1_in),
        .B(alu2_in),
        .Op(Op),
        .R(alu_out)
);

always @(edge clk) begin
        temp_clk<=!clk;
end

always_comb begin
        if (clk) begin
                alu1_in <=a;
                alu2_in<=b;
                Op<=3'b111;
                alu1_out<=alu_out;
        end
        else begin
                alu1_in<=alu1_out;
                alu2_in<=data_in;
                Op<=3'b000;
                alu2_out<=alu_out;
        end
end

always_comb data_out <=alu2_out & {32{valido}};


   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
	 data_out <= 32'b0;
	 valido <= 1'b0;
	 state = S0;
      end
   
      else begin
	 case (state)
	   
	   // S0
	   S0: begin
	      valido <= 1'b0;
	      if (validi) begin
		 a = data_in;
		 next = S1;
	      end
	   end

	   // S1
	   S1: begin
	      if (validi) begin
		 //a *= data_in;
		b=data_in; 
		next = S2;
	      end
	      else
		next = S0;
	   end

	   // S2
	   S2: begin
	      if (validi) begin
		 //a += data_in;
		 a=b;
		b=data_in;
		 data_out <= a;
		 valido <= 1'b1;
	     	 next = S3;
	      end
	     else
	      next = S0;

	   end
	  
	   S3: begin 
            if (validi) begin
	      data_out <= data_out;
	      next = S3;
	      valido <=1'b1;
	    end
	   else
	    next = S0; 
	   end

	 endcase
	 state = next;
	 
      end
   end
endmodule
