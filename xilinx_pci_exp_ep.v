
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
// File       : xilinx_pci_exp_ep.v
//
// Description:  PCI Express Endpoint Core example design top level wrapper.
//
//------------------------------------------------------------------------------
module     xilinx_pci_exp_ep 
(
	F17, F18, E17, D18, E12, D17, C17, C18,
	G15, E14, F13, G16, G14, E16, F14, E15,
	D15, C13, D12, C12, A18, B16, A17, A16, A14, A13, B14, B13,
	C16, H15, H17, J17,
	J15, G18, H18, J18, L18, L17, N17, H16, J14, K15, K17, M18, M16, P18,
	A6, P17, R16, R17,
	V1, V2, V3, D8,
	
								//DEBUG,
								//ADC,
								ADCclk,
								
								//S_OUT,
								//sADC,
                        // PCI Express Fabric Interface

                        pci_exp_txp,
                        pci_exp_txn,
                        pci_exp_rxp,
                        pci_exp_rxn,

                        // System (SYS) Interface

                        sys_clk_p,
                        sys_clk_n,

                        sys_reset1_n,
                        sys_reset2_n,
			refclkout

                        );//synthesis syn_noclockbuf=1
	//output [7:0] DEBUG;
	
	input	F17, F18, E17, D18, E12, D17, C17, C18,
	G15, E14, F13, G16, G14, E16, F14, E15,
	D15, C13, D12, C12, A18, B16, A17, A16, A14, A13, B14, B13,
	J15, G18, H18, J18, L18, L17, N17, H16, J14, K15, K17, M18, M16, P18;
	
	inout H15, H17, C16, J17;
	
	output A6, P17, R16, R17;

	input ADCclk;
	output V1, V2, V3, D8;
		
	wire Bv; //Board version: 1 for new, 0 for KNJN original Dragon
	wire ADC_type; //1 for 12-bit, 0 for 2x8-bit

	wire [3:0] S_OUT;
	assign H15 = Bv?1'bz:S_OUT[0];
	assign H17 = Bv?1'bz:S_OUT[1];
	
	assign A6 = Bv?S_OUT[0]:1'b0;
	assign P17 = Bv?S_OUT[1]:1'b0;
	assign R16 = S_OUT[2];
	assign R17 = S_OUT[3];
	
	wire [2:0] LED;
	assign V2 = LED[0];
	assign V1 = Bv?LED[1]:1'b0;
	assign V3 = Bv?1'b0:LED[1];
	assign D8 = Bv?1'b0:LED[2]; //third led on red dragon
	
	//wire sADC_ext = Bv?J17:C16;

	wire [27:0] ADC;

	assign ADC[0] = Bv?H17:F17;
	assign ADC[1] = Bv?H18:F18;
	assign ADC[2] = Bv?G18:E17;
	assign ADC[3] = Bv?J15:D18;
	assign ADC[4] = Bv?K15:E12;
	assign ADC[5] = Bv?J14:D17;
	assign ADC[6] = Bv?H15:C17;
	assign ADC[7] = Bv?H16:C18;
	assign ADC[8] = Bv?P18:G15;
	assign ADC[9] = Bv?N17:E14;
	assign ADC[10] = Bv?M16:F13;
	assign ADC[11] = Bv?M18:G16;
	assign ADC[12] = Bv?L17:G14;
	assign ADC[13] = Bv?K17:E16;
	assign ADC[14] = Bv?L18:F14;
	assign ADC[15] = Bv?J18:E15;
	assign ADC[16] = D15;
	assign ADC[17] = C13;
	assign ADC[18] = D12;
	assign ADC[19] = C12;
	assign ADC[20] = A18;
	assign ADC[21] = B16;
	assign ADC[22] = A17;
	assign ADC[23] = A16;
	assign ADC[24] = A14;
	assign ADC[25] = A13;
	assign ADC[26] = B14;
	assign ADC[27] = B13;
	
	
	wire ADCc;
	wire ADCc_2x;
	
	clockdoubler clockdoubler_inst(.CLKIN_IN(ADCclk), .CLKIN_IBUFG_OUT(ADCc), .CLK0_OUT(ADCc_2x));

	//133mhz test counter on adc clock
	reg [24:0] mycnt2;
	always @(posedge ADCc)
		 mycnt2 <= mycnt2+1;
	//assign LED[0] = mycnt2[24];
	//assign LED[1] = ~mycnt2[24];
	
	//DAC control
	wire [31:0] DacData;
   reg[1:0] tmp_cntr_1; always @(posedge ADCc) tmp_cntr_1 <= tmp_cntr_1 + 1;
	reg [31:0] DAC_cnt; always @(posedge tmp_cntr_1[1]) DAC_cnt <= DAC_cnt + 1;
	wire [7:0] DAC_regdata [3:0];
	assign DAC_regdata[0] = DacData[31:24];//8'b11000000;
	assign DAC_regdata[1] = DacData[23:16];//8'b10000000;
	assign DAC_regdata[2] = DacData[15:8];//8'b11000000;
	assign DAC_regdata[3] = DacData[7:0];//8'b10000000;
	wire [15:0] DAC_data = {5'b11111, DAC_cnt[17:16], 1'b1, DAC_regdata[DAC_cnt[17:16]]};
	reg DAC_control;
	always @(posedge tmp_cntr_1[1])
	DAC_control <= &DAC_cnt[15:13] & (&DAC_cnt[8:1] ? ~DAC_cnt[0] : DAC_data[~DAC_cnt[12:9]]);


	
	


	wire sADC = ADC_type ? 1'bz : DAC_control;
	//assign sADC_ext = sADC_int;
	assign J17 = Bv?sADC:1'b0;
	assign C16 = Bv?1'b0:sADC;
	
	
	wire [11:0] ADC1_12b = {ADC[8], ADC[10], ADC[9], ADC[11], ADC[12], ADC[13], 
						 ADC[14], ADC[15], sADC, ADC[0], ADC[1], ADC[2]};
						 
	wire [11:0] ADC2_12b = {ADC[16], ADC[17], ADC[18], ADC[19], ADC[20], ADC[21], 
						 ADC[22], ADC[23], ADC[24], ADC[25], ADC[26], ADC[27]};
			
	wire [11:0] ADC1_8b = {4'd0, ADC[7], ADC[6], ADC[5], ADC[4], ADC[3], ADC[2], ADC[1], ADC[0]};

	wire [11:0] ADC2_8b = {4'd0, ADC[15], ADC[14], ADC[13], ADC[12], ADC[11], ADC[10], ADC[9], ADC[8]};

	wire [11:0] ADC1 = ADC_type ? ADC1_12b : ADC1_8b;
	wire [11:0] ADC2 = ADC_type ? ADC2_12b : ADC2_8b;

    //-------------------------------------------------------
    // 1. PCI Express Fabric Interface
    //-------------------------------------------------------

    // Tx
    output    [(1 - 1):0]           pci_exp_txp;
    output    [(1 - 1):0]           pci_exp_txn;

    // Rx
    input     [(1 - 1):0]           pci_exp_rxp;
    input     [(1 - 1):0]           pci_exp_rxn;


    //-------------------------------------------------------
    // 4. System (SYS) Interface
    //-------------------------------------------------------

    input                                             sys_clk_p;
    input                                             sys_clk_n;
    input                                             sys_reset1_n;
    input                                             sys_reset2_n;

    output					      refclkout;




    //-------------------------------------------------------
    // Local Wires
    //-------------------------------------------------------

    wire                                              sys_clk_c;

    wire                                              sys_reset1_n_c; 
    wire                                              sys_reset2_n_c; 
    wire                                              trn_clk_c;//synthesis attribute max_fanout of trn_clk_c is "100000"
    wire                                              trn_reset_n_c;
    wire                                              trn_lnk_up_n_c;
    wire                                              cfg_trn_pending_n_c;
    wire [(64 - 1):0]             cfg_dsn_n_c;
    wire                                              trn_tsof_n_c;
    wire                                              trn_teof_n_c;
    wire                                              trn_tsrc_rdy_n_c;
    wire                                              trn_tdst_rdy_n_c;
    wire                                              trn_tsrc_dsc_n_c;
    wire                                              trn_terrfwd_n_c;
    wire                                              trn_tdst_dsc_n_c;
    wire    [(64 - 1):0]         trn_td_c;
    wire    [7:0]          trn_trem_n_c;
    wire    [( 4 -1 ):0]       trn_tbuf_av_c;

    wire                                              trn_rsof_n_c;
    wire                                              trn_reof_n_c;
    wire                                              trn_rsrc_rdy_n_c;
    wire                                              trn_rsrc_dsc_n_c;
    wire                                              trn_rdst_rdy_n_c;
    wire                                              trn_rerrfwd_n_c;
    wire                                              trn_rnp_ok_n_c;

    wire    [(64 - 1):0]         trn_rd_c;
    wire    [7:0]          trn_rrem_n_c;
    wire    [6:0]      trn_rbar_hit_n_c;
    wire    [7:0]       trn_rfc_nph_av_c;
    wire    [11:0]      trn_rfc_npd_av_c;
    wire    [7:0]       trn_rfc_ph_av_c;
    wire    [11:0]      trn_rfc_pd_av_c;
    wire                                              trn_rcpl_streaming_n_c;

    wire    [31:0]         cfg_do_c;
    wire    [31:0]         cfg_di_c;
    wire    [9:0]         cfg_dwaddr_c;
    wire    [3:0]       cfg_byte_en_n_c;
    wire    [47:0]       cfg_err_tlp_cpl_header_c;

    wire                                              cfg_wr_en_n_c;
    wire                                              cfg_rd_en_n_c;
    wire                                              cfg_rd_wr_done_n_c;
    wire                                              cfg_err_cor_n_c;
    wire                                              cfg_err_ur_n_c;
    wire                                              cfg_err_cpl_rdy_n_c;
    wire                                              cfg_err_ecrc_n_c;
    wire                                              cfg_err_cpl_timeout_n_c;
    wire                                              cfg_err_cpl_abort_n_c;
    wire                                              cfg_err_cpl_unexpect_n_c;
    wire                                              cfg_err_posted_n_c;
    wire                                              cfg_err_locked_n_c;
    wire                                              cfg_interrupt_n_c;
    wire                                              cfg_interrupt_rdy_n_c;

    wire                                              cfg_interrupt_assert_n_c;
    wire [7 : 0]                                      cfg_interrupt_di_c;
    wire [7 : 0]                                      cfg_interrupt_do_c;
    wire [2 : 0]                                      cfg_interrupt_mmenable_c;
    wire                                              cfg_interrupt_msienable_c;

    wire                                              cfg_turnoff_ok_n_c;
    wire                                              cfg_to_turnoff_n;
    wire                                              cfg_pm_wake_n_c;
    wire    [2:0]        cfg_pcie_link_state_n_c;
    wire    [7:0]       cfg_bus_number_c;
    wire    [4:0]       cfg_device_number_c;
    wire    [2:0]       cfg_function_number_c;
    wire    [15:0]          cfg_status_c;
    wire    [15:0]          cfg_command_c;
    wire    [15:0]          cfg_dstatus_c;
    wire    [15:0]          cfg_dcommand_c;
    wire    [15:0]          cfg_lstatus_c;
    wire    [15:0]          cfg_lcommand_c;
    


//-------------------------------------------------------
// Virtex5-FX Global Clock Buffer
//-------------------------------------------------------
  IBUFDS refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));  // 100 MHz


  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------

  IBUF sys_reset1_n_ibuf (.O(sys_reset1_n_c), .I(sys_reset1_n));
  IBUF sys_reset2_n_ibuf (.O(sys_reset2_n_c), .I(sys_reset2_n));

  wire sys_reset_n_c = (sys_reset1_n_c & sys_reset2_n_c);

  //-------------------------------------------------------
  // Endpoint Implementation Application
  //-------------------------------------------------------
pci_exp_64b_app app (
		//.DEBUG(DEBUG),
		.ADC1(ADC1),
		.ADC2(ADC2),
		.ADCc(ADCc),
		.ADC_type(ADC_type),
		.Bv(Bv),
		.LED(LED),
		.ADCc_2x(ADCc_2x),
		.S_OUT(S_OUT),
		.DacData(DacData),

      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // I
      .trn_reset_n( trn_reset_n_c ),           // I
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // I

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // O [63/31:0]
      .trn_trem( trn_trem_n_c ),               // O [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // O
      .trn_teof_n( trn_teof_n_c ),             // O
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // O
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // O
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // I
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // I
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // O
      .trn_tbuf_av( trn_tbuf_av_c ),           // I [4/3:0]


      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // I [63/31:0]
      .trn_rrem( trn_rrem_n_c ),               // I [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // I
      .trn_reof_n( trn_reof_n_c ),             // I
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // I
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // I
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // O
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // I
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // O
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // I [6:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // I [11:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // I [7:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // I [11:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // I [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),  // O

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                   // I [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),               // I
      .cfg_di( cfg_di_c ),                                   // O [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                     // O
      .cfg_dwaddr( cfg_dwaddr_c ),                           // O
      .cfg_wr_en_n( cfg_wr_en_n_c ),                         // O
      .cfg_rd_en_n( cfg_rd_en_n_c ),                         // O
      .cfg_err_cor_n( cfg_err_cor_n_c ),                     // O
      .cfg_err_ur_n( cfg_err_ur_n_c ),                       // O
      .cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),             // I
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                   // O
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),     // O
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),         // O
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),   // O
      .cfg_err_posted_n( cfg_err_posted_n_c ),               // O
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),   // O [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                 // O
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),         // I

      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),     // O
      .cfg_interrupt_di(cfg_interrupt_di_c),                 // O [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                 // I [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),     // I [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),   // I
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),               // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                     // O
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),     // I [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),             // O
      .cfg_dsn( cfg_dsn_n_c),                                // O [63:0]

      .cfg_bus_number( cfg_bus_number_c ),                   // I [7:0]
      .cfg_device_number( cfg_device_number_c ),             // I [4:0]
      .cfg_function_number( cfg_function_number_c ),         // I [2:0]
      .cfg_status( cfg_status_c ),                           // I [15:0]
      .cfg_command( cfg_command_c ),                         // I [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                         // I [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                       // I [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                         // I [15:0]
      .cfg_lcommand( cfg_lcommand_c )                        // I [15:0]

      );


endpoint_blk_plus_v1_14 ep  (


      //
      // PCI Express Fabric Interface
      //

      .pci_exp_txp( pci_exp_txp ),             // O [7/3/0:0]
      .pci_exp_txn( pci_exp_txn ),             // O [7/3/0:0]
      .pci_exp_rxp( pci_exp_rxp ),             // O [7/3/0:0]
      .pci_exp_rxn( pci_exp_rxn ),             // O [7/3/0:0]


      //
      // System ( SYS ) Interface
      //

      .sys_clk( sys_clk_c ),                                 // I

      .sys_reset_n( sys_reset_n_c ),                         // I
      .refclkout( refclkout ),       // O



      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // O
      .trn_reset_n( trn_reset_n_c ),           // O
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // O

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // I [63/31:0]
        .trn_trem_n( trn_trem_n_c ),             // I [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // I
      .trn_teof_n( trn_teof_n_c ),             // I
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // I
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // I
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // O
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // O
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // I
      .trn_tbuf_av( trn_tbuf_av_c ),           // O [4/3:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // O [63/31:0]
        .trn_rrem_n( trn_rrem_n_c ),             // O [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // O
      .trn_reof_n( trn_reof_n_c ),             // O
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // O
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // O
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // I
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // O
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // I
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // O [6:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // O [11:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // O [7:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // O [11:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // O [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),       // I

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                    // O [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),                // O
      .cfg_di( cfg_di_c ),                                    // I [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                      // I [3:0]
      .cfg_dwaddr( cfg_dwaddr_c ),                            // I [9:0]
      .cfg_wr_en_n( cfg_wr_en_n_c ),                          // I
      .cfg_rd_en_n( cfg_rd_en_n_c ),                          // I

      .cfg_err_cor_n( cfg_err_cor_n_c ),                      // I
      .cfg_err_ur_n( cfg_err_ur_n_c ),                        // I
      .cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),              // O
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                    // I
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),      // I
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),          // I
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),    // I
      .cfg_err_posted_n( cfg_err_posted_n_c ),                // I
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),    // I [47:0]
      .cfg_err_locked_n( 1'b1 ),                // I
      .cfg_interrupt_n( cfg_interrupt_n_c ),                  // I
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),          // O

      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),      // I
      .cfg_interrupt_di(cfg_interrupt_di_c),                  // I [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                  // O [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),      // O [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),    // O
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),                // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                      // I
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),      // O [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),              // I
      .cfg_bus_number( cfg_bus_number_c ),                    // O [7:0]
      .cfg_device_number( cfg_device_number_c ),              // O [4:0]
      .cfg_function_number( cfg_function_number_c ),          // O [2:0]
      .cfg_status( cfg_status_c ),                            // O [15:0]
      .cfg_command( cfg_command_c ),                          // O [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                          // O [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                        // O [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                          // O [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // O [15:0]
      .cfg_dsn( cfg_dsn_n_c),                                 // I [63:0]


       // The following is used for simulation only.  Setting
       // the following core input to 1 will result in a fast
       // train simulation to happen.  This bit should not be set
       // during synthesis or the core may not operate properly.
       `ifdef SIMULATION
       .fast_train_simulation_only(1'b1)
       `else
       .fast_train_simulation_only(1'b0)
       `endif

);


endmodule // XILINX_PCI_EXP_EP
