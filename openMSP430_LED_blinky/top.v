`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:37 11/06/2012 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
    input clk,
    input rst,
    output reg led,
	 input dbg_rxd,
	 output dbg_txd,
	 input dbg_en,
	 input cpu_rst
    );
	 wire rstbar,cpurstbar;
	 assign rstbar = ~rst;
	 assign cpurstbar = ~cpu_rst;
	 
	 wire pmem_cs,dmem_cs,per_cs;
	 wire dmem_csbar,pmem_csbar;
	 assign dmem_cs = ~dmem_csbar;
	 assign pmem_cs = ~pmem_csbar;
	 
	 wire [1:0] pmem_webar,dmem_webar;
	 wire [1:0] pmem_we,dmem_we,per_we;
	 assign pmem_we = ~pmem_webar;
	 assign dmem_we = ~dmem_webar;
	
	 
	 wire [10:0] PMEM_ADDR; // 4KB PMEM. 16bits => 11 address lines needed
	 wire [6:0] DMEM_ADDR; // 256bytes DMEM . 16bits => 7 address bits
	 wire [7:0] PER_ADDR; // 512 bytes Peripheral space. 16 bits => 8 address bits
	 
	 // IN refers to "into" the memeory and OUT refers to "out" of the memory
	 wire [15:0] PMEM_DATA_IN;
	 wire [15:0] PMEM_DATA_OUT;
	 wire [15:0] DMEM_DATA_IN;
	 wire [15:0] DMEM_DATA_OUT;
	 wire [15:0] PER_DATA_IN;
	 wire [15:0] PER_DATA_OUT;
	 
	 
	 //ONLY Peripheral
	 assign PER_DATA_OUT = 0;
	 always @(posedge clk or posedge rst) begin
		if(rst) led <= 0;
		else if(per_we[0] & per_cs)
				if(PER_ADDR == 0)
					led <= PER_DATA_IN[0];
	 end
	 
	 
	 // Program memory
	 ram2k8 program_memory_hi (
  .clka(clk), // input clka
  .wea(pmem_we[1]), // input [0 : 0] wea
  .addra(PMEM_ADDR), // input [10 : 0] addra
  .dina(PMEM_DATA_IN[15:8]), // input [7 : 0] dina
  .douta(PMEM_DATA_OUT[15:8]) // output [7 : 0] douta
);
	 ram2k8 program_memory_lo (
  .clka(clk), // input clka
  .wea(pmem_we[0]), // input [0 : 0] wea
  .addra(PMEM_ADDR), // input [10 : 0] addra
  .dina(PMEM_DATA_IN[7:0]), // input [7 : 0] dina
  .douta(PMEM_DATA_OUT[7:0]) // output [7 : 0] douta
);
	 // Data memory
	 ram128b8 data_memory_hi (
  .clka(clk), // input clka
  .wea(dmem_we[1]), // input [0 : 0] wea
  .addra(DMEM_ADDR), // input [6 : 0] addra
  .dina(DMEM_DATA_IN[15:8]), // input [7 : 0] dina
  .douta(DMEM_DATA_OUT[15:8]) // output [7 : 0] douta
);
	 ram128b8 data_memory_lo (
  .clka(clk), // input clka
  .wea(dmem_we[0]), // input [0 : 0] wea
  .addra(DMEM_ADDR), // input [6 : 0] addra
  .dina(DMEM_DATA_IN[7:0]), // input [7 : 0] dina
  .douta(DMEM_DATA_OUT[7:0]) // output [7 : 0] douta
);
	 
	openMSP430 core0(
	
	// OUTPUTs
    .aclk(),                               // ASIC ONLY: ACLK
    .aclk_en(),                            // FPGA ONLY: ACLK enable
    .dbg_freeze(),                         // Freeze peripherals
    .dbg_i2c_sda_out(),                    // Debug interface: I2C SDA OUT
    .dbg_uart_txd(dbg_txd),                       // Debug interface: UART TXD
    .dco_enable(),                         // ASIC ONLY: Fast oscillator enable
    .dco_wkup(),                           // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr(DMEM_ADDR),                          // Data Memory address
    .dmem_cen(dmem_csbar),                           // Data Memory chip enable (low active)
    .dmem_din(DMEM_DATA_IN),                           // Data Memory data input
    .dmem_wen(dmem_webar),                           // Data Memory write enable (low active)
    .irq_acc(),                            // Interrupt request accepted (one-hot signal)
    .lfxt_enable(),                        // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup(),                          // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk(),                               // Main system clock
    .per_addr(PER_ADDR),                           // Peripheral address
    .per_din(PER_DATA_IN),                            // Peripheral data input
    .per_we(per_we),                             // Peripheral write enable (high active)
    .per_en(per_cs),                             // Peripheral enable (high active)
    .pmem_addr(PMEM_ADDR),                          // Program Memory address
    .pmem_cen(pmem_csbar),                           // Program Memory chip enable (low active)
    .pmem_din(PMEM_DATA_IN),                           // Program Memory data input (optional)
    .pmem_wen(pmem_webar),                           // Program Memory write enable (low active) (optional)
    .puc_rst(),                            // Main system reset
    .smclk(),                              // ASIC ONLY: SMCLK
    .smclk_en(),                           // FPGA ONLY: SMCLK enable

// INPUTs
    .cpu_en(1'b1),                             // Enable CPU code execution (asynchronous and non-glitchy)
    .dbg_en(dbg_en),                             // Debug interface enable (asynchronous and non-glitchy)
    .dbg_i2c_addr(1'b0),                       // Debug interface: I2C Address
    .dbg_i2c_broadcast(1'b0),                  // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl(1'b0),                        // Debug interface: I2C SCL
    .dbg_i2c_sda_in(1'b0),                     // Debug interface: I2C SDA IN
    .dbg_uart_rxd(dbg_rxd),                       // Debug interface: UART RXD (asynchronous)
    .dco_clk(clk),                            // Fast oscillator (fast clock)
    .dmem_dout(DMEM_DATA_OUT),                          // Data Memory data output
    .irq(1'b0),                                // Maskable interrupts
    .lfxt_clk(1'b0),                           // Low frequency oscillator (typ 32kHz)
    .nmi(1'b0),                                // Non-maskable interrupt (asynchronous)
    .per_dout(PER_DATA_OUT),                           // Peripheral data output
    .pmem_dout(PMEM_DATA_OUT),                          // Program Memory data output
    .reset_n(cpurstbar),                            // Reset Pin (low active, asynchronous and non-glitchy)
    .scan_enable(1'b0),                        // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode(1'b0),                          // ASIC ONLY: Scan mode
    .wkup(1'b0)                                // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
);


endmodule
