/*
 * Turning all checks on with check5
 */
`ifdef check5
`define check1 
`define check2 
`define check3 
`define check4
`endif 

module toplevel_property 
  (
   input 	      clk, rst, validi,
   input [7:0]       data_in, 
   input logic 	      valido, 
   input logic [7:0] data_out
   );

/*------------------------------------
 *
 *        CHECK # 1. Check that when 'rst' is asserted (==1) that data_out == 0
 *
 *------------------------------------ */

`ifdef check1


property reset_asserted;
   @(posedge clk) rst |-> !data_out; 
endproperty

reset_check: assert property(reset_asserted)
  $display($stime,,,"\t\tRESET CHECK PASS:: rst_=%b data_out=%0d \n",
	   rst, data_out);
else $display($stime,,,"\t\RESET CHECK FAIL:: rst_=%b data_out=%0d \n",
	      rst, data_out); 
`endif

/* ------------------------------------
 * Check valido assertion to hold 
 *
 *       CHECK # 2. Check that valido is asserted when validi=1 for three
 *                  consecutive clk cycles
 * 
 * ------------------------------------ */

`ifdef check2
property valido_high;
	@(posedge clk)// disable iff(rst)
	 validi[*3] |=> valido;
endproperty

valido_check: assert property(valido_high)
  $display($stime,,,"\t\tVALIDO CHECK PASS:: validi=%b valido=%0d \n",
           validi, valido);
else $display($stime,,,"\t\VALIDO CHECK FAIL:: validi=%b valido=%0d \n",
              validi, valido);

`endif

/* ------------------------------------
 * Check valido not asserted wrong 
 *
 *       CHECK # 3. Check that valido is not asserted when validi=1 for only two, one
 *                  or zero consecutive clk cycles
 * 
 * ------------------------------------ */

`ifdef check3

property valido_low;
        @(posedge clk) disable iff (rst)
	  validi[*2] || validi || !validi |-> !valido; 
endproperty


valido_check_low: assert property(valido_low)
$display($stime,,,"\t\tVALIDO LOW  CHECK PASS:: validi=%b valido=%0d \n",
           validi, valido);

else $display($stime,,,"\t\VALIDO LOW  CHECK FAIL:: validi=%b valido=%0d \n",
              validi, valido);
 


`endif


/* ------------------------------------
 * Check data_out value
 *
 *       CHECK # 4. Check that data_out when valido=1 is equal to a*b+c where a is data_in
 *       two cycles back, b is data_in one cycle back, and c is the present data_in
 *
 * ------------------------------------ */

`ifdef check4

property data_out_val;
        @(posedge clk) disable iff (rst)
        valido |-> data_out == ($past(data_in,3) * $past(data_in,2) + $past(data_in));
endproperty

        data_out_check: assert property (data_out_val)
        $display ($time,,"\t\t DATA OUT CHECK PASS :: data_out=%0d valido=%0d a=%0d b= %0d c=%0d \n", data_out, valido, $past(data_in,3), $past(data_in,2),$past(data_in));

else $display($time,,,"\t\ DATA OUT CHECK FAIL::  data_out=%0d valido=%0d a=%0d b= %0d c=%0d \n", data_out, valido, $past(data_in,3), $past(data_in,2),$past(data_in));


`endif


endmodule
