module test_toplevel;

   logic clk, rst, validi;
   
   logic [7:0] data_in;
   wire 	valido;
   wire [7:0]  data_out;
   
   toplevel dut 
     (
      clk, rst, validi,
      data_in,
      valido,
      data_out
      );
   
   bind toplevel toplevel_property toplevel_bind 
     (
      clk, rst, validi,
      data_in,
      valido,
      data_out
      );

covergroup alu_cg(input logic [2:0] op, logic [7:0] a,logic [7:0] b) @(posedge clk);
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
alu_cg cg_mult= new(dut.mult_op, dut.temp_out, dut.data_in);
alu_cg cg_add= new(dut.add_op, dut.add_in, dut.data_in);

//end



//initial begin
#330;
$display("Coverage (cg_add) = %0.2f %%", cg_mult.get_inst_coverage());
$display("Coverage (cg_mult) = %0.2f %%", cg_add.get_inst_coverage());
    end


   initial begin

      clk=1'b0;
      set_stim;
      @(posedge clk); $finish(2);
   end

//initial begin
//#330;
//$display("Coverage (cg_add) = %0.2f %%", cg_mult.get_inst_coverage());
//$display("Coverage (cg_mult) = %0.2f %%", cg_add.get_inst_coverage());
//    end


   always @(posedge clk) 
     $display($stime,,,"rst=%b clk=%b validi=%b DIN=%0d valido=%b DOUT=%0d",
	      rst, clk, validi, data_in, valido, data_out);
always #5 clk=!clk;

   task set_stim;
      rst=1'b0; validi=0'b1; data_in=8'b1;
      @(negedge clk) rst=1;
      @(negedge clk) rst=0;
      
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b1; data_in+=8'b1;
      @(negedge clk); validi=1'b0; data_in+=8'b1;

 
      @(negedge clk);
   endtask

endmodule
