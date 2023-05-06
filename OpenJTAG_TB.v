/* See Component Author Guide Section on Simulation for more information */

/* 1ns is the reference time, 100ps is the precision, i.e #33.1 is a delay of 33100 ps, #33.01 is a delay of 33000 ps */
`timescale 1ns/100ps

`include "defines.v"

`include "cypress.v"

`include "CyControlReg_v1_80.v"

`include "OpenJTAGBlock.v"

`include "CyStatusReg_v1_90.v"

module OpenJTAG_TB;	/* A testbench is a special type of module without any inputs or outputs */

	reg clk;
	reg cpu_clk;
	wire dInReq;
	wire dOutReq;
	wire stall;
	reg [3:0] flagsOut;
	reg [3:0] bitCountOut;
	reg [7:0] bitsOut;

	/* Invoke the design to be tested. Syntax is: 
	 * Module Name #(.parameter1(value1), .parameter2(value2), .....) Instance name (.terminal1(signal1), .terminal2(signal2), ....);
	 */
	OpenJTAGBlock dut (.clock(clk), .dInReq(dInReq), .dOutReq(dOutReq), .stall(stall));

	initial	/* This loop runs only once */ 
	begin
$dumpfile("openjtag_tb.vcd");
$dumpvars(0,OpenJTAG_TB);
//$dumpvars;
		clk = 0;


		// 
		#20;
		wait(dInReq);

		dut.Datapath_1_u0.fifo0_write(8'b00010101);  // set MSB
		#1;
		wait(stall) ;
		#20;
		dut.CtrlReg.Sync.ctrl_reg.control_write(8'h80);  // proceed
		#20;
		dut.Datapath_1_u0.fifo0_write(8'b10010000);  // set clock
		#1;
		wait(stall) ;
		#20;
		dut.CtrlReg.Sync.ctrl_reg.control_write(8'h80);  // proceed
		#20;
		dut.Datapath_1_u0.fifo0_write(8'b00000011);  // software reset
		#20;

		dut.Datapath_1_u0.fifo0_write(8'b01100110);  // Shift 4 bits TMS low
		#20;
		dut.Datapath_1_u0.fifo0_write(8'b11111001);  // 0b1001
		#20;

		wait(dOutReq);
		#2;
		dut.Datapath_1_u0.fifo1_read({flagsOut, bitCountOut});  // read fifo output
		dut.Datapath_2_u0.fifo1_read(bitsOut);  // read fifo output
		#10;

		wait(dOutReq);
		#2;
		dut.Datapath_1_u0.fifo1_read({flagsOut, bitCountOut});  // read fifo output
		dut.Datapath_2_u0.fifo1_read(bitsOut);  // read fifo output
		#200;

		$finish;



		/* To access an instance/parameter/variable within another module, the dot (.) convention is used */
//		dut.UDB2FIFO_DP.aux_ctrl = dut.UDB2FIFO_DP.aux_ctrl | 03;
//		#20;
//		dut.UDB2FIFO_DP.fifo0_read(FIFO0_dat);
//		dut.UDB2FIFO_DP.fifo1_read(FIFO1_dat);
//		@(negedge clk) TrigIn = 1;
//		@(negedge clk) TrigIn = 0;
//		dut.UDB2FIFO_DP.fifo0_read(FIFO0_dat);
//		dut.UDB2FIFO_DP.fifo1_read(FIFO1_dat);
//		#20;
//		dut.UDB2FIFO_DP.fifo0_read(FIFO0_dat);
//		dut.UDB2FIFO_DP.fifo1_read(FIFO1_dat);
//		@(negedge clk) TrigIn = 1;
//		@(negedge clk) TrigIn = 0;
//		dut.UDB2FIFO_DP.fifo0_read(FIFO0_dat);
//		dut.UDB2FIFO_DP.fifo1_read(FIFO1_dat);

//		#200 $finish;
	end

//	always @clk
//	begin
//		dut.UDB2FIFO_DP.fifo0_read(FIFO0_dat);
//		dut.UDB2FIFO_DP.fifo1_read(FIFO1_dat);
//	end

	always // UDB Clock generator
	begin
		begin
			#4 clk = !clk;	/* every 4 reference time units, toggle clock. Ensure that clock is initialized to 0 or 1, or this line makes no sense */
		end  
	end

	initial  // CPU clock generator
	begin
		cpu_clk = 0;
		while(1)
		begin
			/* connect the instance's cpu_clk to the testbench's cpu_clk */
			dut.Datapath_1_u0.cpu_clock = cpu_clk;
			dut.Datapath_2_u0.cpu_clock = cpu_clk;
			dut.StalledCmd.sts.sts_reg.cpu_clock = cpu_clk;
			dut.StatusReg.sts.sts_reg.cpu_clock = cpu_clk;
			dut.CtrlReg.Sync.ctrl_reg.cpu_clock = cpu_clk;

			#1 cpu_clk = !cpu_clk;	/* cpu_clk is the freq at which CPU reads and writes are simulated */
		end
	end

endmodule    
