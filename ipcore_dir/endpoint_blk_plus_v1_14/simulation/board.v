
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : board.v
//------------------------------------------------------------------------------
//
// Description:  Top level testbench
//
//------------------------------------------------------------------------------


`include "board_common.v"

module board;

parameter          REF_CLK_FREQ                 = 0;      // 0 - 100 MHz, 1 - 250 MHz

localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                        (REF_CLK_FREQ == 1) ? 2000 : 0;

integer             i;

//
// System reset
//

reg                cor_sys_reset_n;

//
// System clock
//

wire               rp_sys_clk;

wire               cor_sys_clk_p;
wire               cor_sys_clk_n;

//
// PCI-Express facric interface
//
wire  [(1 - 1):0]  cor_pci_exp_txn;
wire  [(1 - 1):0]  cor_pci_exp_txp;
wire  [(1 - 1):0]  cor_pci_exp_rxn;
wire  [(1 - 1):0]  cor_pci_exp_rxp;

//
// PCI-Express End Point Instance
//
xilinx_pci_exp_ep xilinx_pci_exp_ep(

        // SYS Inteface
        .sys_clk_p(cor_sys_clk_p),
        .sys_clk_n(cor_sys_clk_n),

        // PCI-Express Interface
        .pci_exp_txn(cor_pci_exp_txn),
        .pci_exp_txp(cor_pci_exp_txp),
        .pci_exp_rxn(cor_pci_exp_rxn),
        .pci_exp_rxp(cor_pci_exp_rxp),

        .sys_reset_n(cor_sys_reset_n)
);


xilinx_pcie_2_0_rport_v6 # (
 
      .REF_CLK_FREQ(0),
      .PL_FAST_TRAIN("TRUE"),
      .LINK_CAP_MAX_LINK_WIDTH(6'b1),
      .DEVICE_ID(16'h0007),
      .ALLOW_X8_GEN2("FALSE"),
      .LINK_CAP_MAX_LINK_SPEED(4'b1),
      .LINK_CTRL2_TARGET_LINK_SPEED(4'b1),
      .DEV_CAP_MAX_PAYLOAD_SUPPORTED(3'b000),
      .VC0_TX_LASTPACKET(31),
      .VC0_RX_RAM_LIMIT(1023),
      .VC0_CPL_INFINITE("TRUE"),
      .VC0_TOTAL_CREDITS_PD(154),
      .VC0_TOTAL_CREDITS_CD(154),
      .USER_CLK_FREQ(0+1)

)
RP (
        // SYS Inteface
        .sys_clk(rp_sys_clk),
        .sys_reset_n(cor_sys_reset_n),

        // PCI-Express Interface
        .pci_exp_txn(cor_pci_exp_rxn),
        .pci_exp_txp(cor_pci_exp_rxp),
        .pci_exp_rxn(cor_pci_exp_txn),
        .pci_exp_rxp(cor_pci_exp_txp)

);


sys_clk_gen  # (

      .halfcycle(REF_CLK_HALF_CYCLE),
      .offset(0)

)
SYS_CLK_GEN_DSPORT (

          .sys_clk(rp_sys_clk)

          );


sys_clk_gen_ds  # (

      .halfcycle(REF_CLK_HALF_CYCLE), 
      .offset(0)

)   
SYS_CLK_GEN_COR (

          .sys_clk_p(cor_sys_clk_p),
          .sys_clk_n(cor_sys_clk_n)

          );



initial begin
  if ($test$plusargs ("dump_all")) begin
`ifdef NCV //Cadence TRN dump
    $recordsetup(
  `ifdef BOARDx01
                   "design=boardx01",
  `endif
  `ifdef BOARDx04
                   "design=boardx04",
  `endif
  `ifdef BOARDx08
                   "design=boardx08",
  `endif

                   "compress",
                   "wrapsize=1G",
                   "version=1",
                   "run=1");
    $recordvars();
`else
  `ifdef VCS //Synopsys VPD dump
    `ifdef BOARDx01
      $vcdplusfile("boardx01.vpd");
    `endif
    `ifdef BOARDx04
      $vcdplusfile("boardx04.vpd");
    `endif
    `ifdef BOARDx08
      $vcdplusfile("boardx08.vpd");
    `endif
    $vcdpluson;
    $vcdplusglitchon;
    $vcdplusflush;
  `else
    // VCD dump
    `ifdef BOARDx01
      $dumpfile("boardx01.vcd");
    `endif
    `ifdef BOARDx04
      $dumpfile("boardx04.vcd");
    `endif
    `ifdef BOARDx08
      $dumpfile("boardx08.vcd");
    `endif

    $dumpvars(0, board);
  `endif
`endif
  end

  $display("[%t] : System Reset Asserted...", $realtime);
  cor_sys_reset_n = 1'b0;

         for (i = 0; i < 500; i = i + 1) begin

                 @(posedge cor_sys_clk_p);

         end

  $display("[%t] : System Reset De-asserted...", $realtime);

         cor_sys_reset_n = 1'b1;

end

endmodule // BOARD


