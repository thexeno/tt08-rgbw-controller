///////////////////////////////////////////////////////////////////////////////
// Description:   	Simple test bench for SPI Master and Slave modules
///////////////////////////////////////////////////////////////////////////////

module SPI_Slave_TB ();
 
  parameter SPI_MODE = 1; // CPOL = 0, CPHA = 1
  parameter SPI_CLK_DELAY = 20;  // 2.5 MHz
  parameter MAIN_CLK_DELAY = 2;  // 25 MHz

  wire w_CPOL; // clock polarity
  wire w_CPHA; // clock phase

  assign w_CPOL = (SPI_MODE == 2) | (SPI_MODE == 3);
  assign w_CPHA = (SPI_MODE == 1) | (SPI_MODE == 3);

  reg r_Rst_L 	= 1'b1;
  //reg nr_Rst_L 	= 1'b1;

  reg [7:0] dataPayload[0:255];
  reg [7:0] dataLength;
 
  // CPOL=0, clock idles 0.  CPOL=1, clock idles 1
//  logic r_SPI_Clk   = w_CPOL ? 1'b1 : 1'b0;
  wire w_SPI_Clk;
  reg r_SPI_En	= 1'b0;
  reg r_Clk   	= 1'b0;
  reg w_SPI_CS_n;
  wire w_SPI_MOSI;
  wire w_SPI_MISO;

  // Master Specific
  reg [7:0] r_Master_TX_Byte = 0;
  reg r_Master_TX_DV = 1'b0;
  reg r_Master_CS_n = 1'b1;
  wire w_Master_TX_Ready;
  wire r_Master_RX_DV;
  wire [7:0] r_Master_RX_Byte;

  // Slave Specific
  wire   	w_Slave_RX_DV;
  reg     	r_Slave_TX_DV;
  wire [7:0] w_Slave_RX_Byte;
  reg [7:0] r_Slave_TX_Byte;
  integer cnt;
  // Clock Generators:
  always #(MAIN_CLK_DELAY) r_Clk = ~r_Clk;
//  always #(MAIN_CLK_DELAY) nr_Rst_L = ~r_Rst_L;
 
  // Instantiate UUT
  spiSlave SPI_Slave_UUT
  (

   .sck(w_SPI_Clk),
    	.cs(r_Master_CS_n),
    	.clk(r_Clk),
    	.mosi(w_SPI_MOSI),
    	.reset(r_Rst_L),
    	.rdy(w_Slave_RX_DV),
    	.data(w_Slave_RX_Byte)

   );

  // Instantiate Master to drive Slave
  SPI_Master
  #(.SPI_MODE(SPI_MODE),
	.CLKS_PER_HALF_BIT(2),
	.NUM_SLAVES(1)) SPI_Master_UUT
  (
   // Control/Data Signals,
   .i_Rst_L(r_Rst_L), 	// FPGA Reset
   .i_Clk(r_Clk),     	// FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(r_Master_TX_Byte), 	// Byte to transmit on MOSI
   .i_TX_DV(r_Master_TX_DV),     	// Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(w_Master_TX_Ready),   // Transmit Ready for Byte
   
   // RX (MISO) Signals
   .o_RX_DV(r_Master_RX_DV),   	// Data Valid pulse (1 clock cycle)
   .o_RX_Byte(r_Master_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MISO),
   .o_SPI_MOSI(w_SPI_MOSI)
   );


  // Sends a single byte from master to slave.  Will drive CS on its own.
  task SendSingleByte;
	input [7:0] data;
  begin
	@(posedge r_Clk);
	r_Master_TX_Byte <= data;
	r_Master_TX_DV   <= 1'b1;
	r_Master_CS_n	<= 1'b0;
	@(posedge r_Clk);
	r_Master_TX_DV <= 1'b0;
	@(posedge w_Master_TX_Ready);
	r_Master_CS_n	<= 1'b1;   
	end
  endtask // SendSingleByte


  // Sends a multi-byte transfer from master to slave.  Drives CS on its own.  
  task SendMultiByte;
	integer ii;
	input [7:0] data;
	input [7:0] length;
begin
	@(posedge r_Clk);
	r_Master_CS_n	<= 1'b0;

	for (ii=0; ii<length; ii++)
	begin
  	@(posedge r_Clk);
  	r_Master_TX_Byte <= data[ii];
  	r_Master_TX_DV   <= 1'b1;
  	@(posedge r_Clk);
  	r_Master_TX_DV <= 1'b0;
  	@(posedge w_Master_TX_Ready);
	end
	r_Master_CS_n <= 1'b1;
	end
  endtask // SendMultiByte

  // Sends a multi-byte transfer from master to slave.  Drives CS on its own.  
  task SendSingleByteNoCS;
	integer ii;
	input [7:0] data;
	input [7:0] length;
begin
	@(posedge r_Clk);
   // r_Master_CS_n	<= 1'b0;

	begin
  	@(posedge r_Clk);
  	r_Master_TX_Byte <= data;
  	r_Master_TX_DV   <= 1'b1;
  	@(posedge r_Clk);
  	r_Master_TX_DV <= 1'b0;
  	$display("Wait\n");
  	$display("w_Master_TX_Ready = %d\n", w_Master_TX_Ready);
  	@(posedge w_Master_TX_Ready);
  	//while(w_Master_TX_Ready === 1'b0);
        	$display("Wait!!\n");
	end
	// r_Master_CS_n <= 1'b1;
	end
  endtask // SendMultiByte


  task CS_low;

begin
	@(posedge r_Clk);
	r_Master_CS_n	<= 1'b0;

	end
  endtask // SendMultiByte


  task CS_high;

begin
	@(posedge r_Clk);
	r_Master_CS_n	<= 1'b1;

	end
  endtask // SendMultiByte
    
  initial

	begin
	//$display("reset aL %d\n reset aH %d\n", r_Rst_L, nr_Rst_L);
	r_Rst_L <= 1'b1;
  	repeat(10) @(posedge r_Clk);
        //$display("reset aL %d\n reset aH %d\n", r_Rst_L, nr_Rst_L);
	r_Rst_L <= 1'b0;
  	repeat(10) @(posedge r_Clk);
	r_Rst_L <= 1'b1;
  	repeat(10) @(posedge r_Clk);
	//$display("reset aL %d\n reset aH %d\n", r_Rst_L, nr_Rst_L);


  	dataPayload[0]  <= 8'h55;
  	dataPayload[1]  <= 8'h00;
  	dataPayload[2]  <= 8'h23;
  	dataPayload[3]  <= 8'h00;
  	dataPayload[4]  <= 8'hFF;
  	dataPayload[5]  <= 8'h00;
  	dataPayload[6]  <= 8'h00;
  	dataPayload[7]  <= 8'hA4;
  	dataLength  	<= 8;
	CS_high();
  	repeat(10) @(posedge r_Clk);
  	for (cnt=0; cnt<dataLength; cnt++)
  	begin
  	$display("%d (1)\n", r_Master_CS_n);
  	@(posedge r_Clk);
	CS_low();
  	$display("%d (0)\n", r_Master_CS_n);
	@(posedge r_Clk);
  	$display("%d (0)\n", r_Master_CS_n);
  	SendSingleByteNoCS(dataPayload[cnt], dataLength);
	repeat(10) @(posedge r_Clk);
	CS_high();
  	repeat(10) @(posedge r_Clk);
              	end
  	$display("Before  finish\n");
        	$finish(); 	 

	end // initial begin

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, SPI_Slave_TB);
end

endmodule // SPI_Slave





