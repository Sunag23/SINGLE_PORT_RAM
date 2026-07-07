module ram_top;
	
	import ram_package::*;

	logic clk;
	logic reset;

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		reset=1;
		#10;
		reset = 0;
		#20 reset = 1; 
	end

	ram_if vif(clk, reset);

	RAM DUT (
		.clk(clk),
		.reset(reset),
		.write_enb(vif.write_enb),
		.read_enb(vif.read_enb),
		.data_in(vif.data_in),
		.address(vif.address[4:0]),
		.data_out(vif.data_out)
	);

	
	ram_test test;
	
	initial begin
		
		@(posedge reset);
		
		test = new(vif.DRV, vif.MON);
		
		test.run();
		
		#50; 
		$display("Simulation Finished Successfully");
		$finish;
	end

endmodule
