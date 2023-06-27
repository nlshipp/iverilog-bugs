/* task increment bug */


module inc_test_TB;

	reg clk;
	reg test_inc1;
	reg test_inc2;
	reg [3:0] count;
	wire [1:0] out1;
	wire [1:0] out2;

	inc_test counter_1( .clk(clk), .test_inc(test_inc1), .out(out1));

	inc_test counter_2( .clk(clk), .test_inc(test_inc2), .out(out2));

	initial	
	begin
$dumpfile("inc_test_tb.vcd");
$dumpvars(0,inc_test_TB);

		clk = 0;
		test_inc1 = 0;
		test_inc2 = 0;
		count = 0;
		#7;
		@(negedge clk);
// 		$stop; // type trace on - cont
	
		// out1 is updated only twice in this loop
		for (integer i = 0 ; i < 8 ; i = i + 1)
		begin
			@(posedge clk);
			test_inc1 = 1'b1;
			@(posedge clk);
			test_inc1 = 1'b0;
		end
	
		// out1 is updated the expected 8 times if zero length delays are added
		for (integer j = 0 ; j < 8 ; j = j + 1)
		begin
			@(posedge clk);
			#0 test_inc1 = 1'b1;
			@(posedge clk);
			#0 test_inc1 = 1'b0;
		end

		@(negedge clk);
//		$stop; // type trace off - cont
		#40;
		

		$finish;
	end

	always @(posedge clk)
	begin
		count <= count + 1;
		if ((count % 2) == 1)
		begin
			test_inc2 <= 1;
		end
		else
		begin
			test_inc2 <= 0;
		end
	end

		
	always // Clock generator
	begin
		begin
			#4 clk = !clk;
		end  
	end

endmodule    


module inc_test(clk, test_inc, out);

	input clk;
	input test_inc;
	output [1:0] out;


	reg [1:0] val;
	reg inc;

	wire [1:0] out = val;

	initial
	begin
		val = 0;
	end

	always @(posedge clk)
	begin
		if (test_inc)
		begin
			inc <= 1;
			@(negedge clk);
			inc <= 0;
		end
		else
			inc <= 0;
	end

	always @(posedge inc)
	begin
		val <= val + 1;
	end
endmodule
	

	