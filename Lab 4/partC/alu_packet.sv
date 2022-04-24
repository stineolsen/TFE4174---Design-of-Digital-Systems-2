//Make your struct here
typedef struct {
         rand bit[7:0] a,b;
	 rand bit[2:0] op; //length of op, a and b found in alu.vhd
             	}data_t;


class alu_data;
        //Initialize your struct here
          rand data_t data;
 
        // Class methods(tasks) go here
	task get(output bit[7:0] a, output bit [7:0] b, output bit [2:0] op);
		
	   a=data.a;
	   b= data.b;
	   op=data.op;
	endtask 

        // Constraints
	constraint c_a {data.a inside {[0:127]};}
	constraint c_b {data.b inside {[0:255]};}
	constraint c_op {data.op inside {[0:6]};}


endclass: alu_data

