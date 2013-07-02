//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_64_TX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Transmit Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_CPLD_FMT_TYPE   7'b10_01010
`define BMD_64_MWR_FMT_TYPE    7'b10_00000
`define BMD_64_MWR64_FMT_TYPE  7'b11_00000
`define BMD_64_MRD_FMT_TYPE    7'b00_00000
`define BMD_64_MRD64_FMT_TYPE  7'b01_00000

`define BMD_64_TX_RST_STATE    8'b00000001
`define BMD_64_TX_CPLD_QW1     8'b00000010
`define BMD_64_TX_CPLD_WIT     8'b00000100
`define BMD_64_TX_MWR_QW1      8'b00001000
`define BMD_64_TX_MWR64_QW1    8'b00010000
`define BMD_64_TX_MWR_QWN      8'b00100000

module BMD_TX_ENGINE (
								ADC1, ADC2, ADCc, ADCc_2x, S_OUT, CONFIG_REG_1, CONFIG_REG_2, LED, DEBUG,
                        clk,
                        rst_n,

                        trn_td,
                        trn_trem_n,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tdst_dsc_n,
                        trn_tbuf_av,

                        req_compl_i,    
                        compl_done_o,  

                        req_tc_i,     
                        req_td_i,    
                        req_ep_i,   
                        req_attr_i,
                        req_len_i,         
                        req_rid_i,        
                        req_tag_i,       
                        req_be_i,
                        req_addr_i,     


                        rd_addr_o,   
                        rd_be_o,    
                        rd_data_i,


                        // Initiator Reset
          
                        init_rst_i,

                        mwr_start_i,
                        mwr_int_dis_i,
                        mwr_len_i,
                        mwr_tag_i,
                        mwr_lbe_i,
                        mwr_fbe_i,
                        mwr_addr_i,
								addr_valid,
                        mwr_data_i,
                        mwr_count_i,
                        request_new_buffer_address,
                        mwr_tlp_tc_i,
                        mwr_64b_en_i,
                        mwr_phant_func_dis1_i,
                        mwr_up_addr_i,
                        mwr_relaxed_order_i,
                        mwr_nosnoop_i,
                        mwr_wrr_cnt_i,

                        mrd_start_i,
                        mrd_int_dis_i,
                        mrd_len_i,
                        mrd_tag_i,
                        mrd_lbe_i,
                        mrd_fbe_i,
                        mrd_addr_i,
                        mrd_count_i,
                        mrd_done_i,
                        mrd_tlp_tc_i,
                        mrd_64b_en_i,
                        mrd_phant_func_dis1_i,
                        mrd_up_addr_i,
                        mrd_relaxed_order_i,
                        mrd_nosnoop_i,
                        mrd_wrr_cnt_i,

                        cur_mrd_count_o,

                        cfg_msi_enable_i,
                        cfg_interrupt_n_o,
                        cfg_interrupt_assert_n_o,
                        cfg_interrupt_rdy_n_i,
                        cfg_interrupt_legacyclr,

                        completer_id_i,
                        cfg_ext_tag_en_i,
                        cfg_bus_mstr_enable_i,
                        cfg_phant_func_en_i,
                        cfg_phant_func_supported_i


                        );
	 input ADCc;
	 input ADCc_2x;
	 input [11:0] ADC1;
	 input [11:0] ADC2;
	 output [3:0] S_OUT;
	 input [31:0] CONFIG_REG_1;
	 input [31:0] CONFIG_REG_2;
	 output [2:0] LED;
	 output [3:0]  DEBUG;

    input               clk;
    input               rst_n;
 
    output [63:0]       trn_td;
    output [7:0]        trn_trem_n;
    output              trn_tsof_n;
    output              trn_teof_n;
    output              trn_tsrc_rdy_n;
    output              trn_tsrc_dsc_n;
    input               trn_tdst_rdy_n;
    input               trn_tdst_dsc_n;
    input [5:0]         trn_tbuf_av;

    input               req_compl_i;
    output              compl_done_o;

    input [2:0]         req_tc_i;
    input               req_td_i;
    input               req_ep_i;
    input [1:0]         req_attr_i;
    input [9:0]         req_len_i;
    input [15:0]        req_rid_i;
    input [7:0]         req_tag_i;
    input [7:0]         req_be_i;
    input [10:0]        req_addr_i;
    
    output [6:0]        rd_addr_o;
    output [3:0]        rd_be_o;
    input  [31:0]       rd_data_i;

    input               init_rst_i;

    input               mwr_start_i;
    input               mwr_int_dis_i;
    input  [31:0]       mwr_len_i;
    input  [7:0]        mwr_tag_i;
    input  [3:0]        mwr_lbe_i;
    input  [3:0]        mwr_fbe_i;
    input  [31:0]       mwr_addr_i;
	 input				   addr_valid;
    input  [31:0]       mwr_data_i;
    input  [31:0]       mwr_count_i;
    output              request_new_buffer_address;
    input  [2:0]        mwr_tlp_tc_i;
    input               mwr_64b_en_i;
    input               mwr_phant_func_dis1_i;
    input  [7:0]        mwr_up_addr_i;
    input               mwr_relaxed_order_i;
    input               mwr_nosnoop_i;
    input  [7:0]        mwr_wrr_cnt_i;


    input               mrd_start_i;
    input               mrd_int_dis_i;
    input  [31:0]       mrd_len_i;
    input  [7:0]        mrd_tag_i;
    input  [3:0]        mrd_lbe_i;
    input  [3:0]        mrd_fbe_i;
    input  [31:0]       mrd_addr_i;
    input  [31:0]       mrd_count_i;
    input               mrd_done_i;
    input  [2:0]        mrd_tlp_tc_i;
    input               mrd_64b_en_i;
    input               mrd_phant_func_dis1_i;
    input  [7:0]        mrd_up_addr_i;
    input               mrd_relaxed_order_i;
    input               mrd_nosnoop_i;
    input  [7:0]        mrd_wrr_cnt_i;

    output [15:0]       cur_mrd_count_o;

    input               cfg_msi_enable_i;
    output              cfg_interrupt_n_o;
    output              cfg_interrupt_assert_n_o;
    input               cfg_interrupt_rdy_n_i;
    input               cfg_interrupt_legacyclr;

    input [15:0]        completer_id_i;
    input               cfg_ext_tag_en_i;
    input               cfg_bus_mstr_enable_i;

    input               cfg_phant_func_en_i;
    input [1:0]         cfg_phant_func_supported_i;



    reg [63:0]          trn_td;
    reg [7:0]           trn_trem_n;
    reg                 trn_tsof_n;
    reg                 trn_teof_n;
    reg                 trn_tsrc_rdy_n;
    reg                 trn_tsrc_dsc_n;
 
    reg [11:0]          byte_count;
    reg [06:0]          lower_addr;

    reg                 req_compl_q;                 

    reg [7:0]           bmd_64_tx_state;

    reg                 compl_done_o;
  
    reg [9:0]           cur_mwr_dw_count;
  

    wire [15:0]          TLPMaxNumber = mwr_count_i[15:0];
	 

    wire                cfg_bm_en = cfg_bus_mstr_enable_i;


    assign rd_addr_o = req_addr_i[10:2];
    assign rd_be_o =   req_be_i[3:0];


    always @ (rd_be_o) begin

      casex (rd_be_o[3:0])
      
        4'b1xx1 : byte_count = 12'h004;
        4'b01x1 : byte_count = 12'h003;
        4'b1x10 : byte_count = 12'h003;
        4'b0011 : byte_count = 12'h002;
        4'b0110 : byte_count = 12'h002;
        4'b1100 : byte_count = 12'h002;
        4'b0001 : byte_count = 12'h001;
        4'b0010 : byte_count = 12'h001;
        4'b0100 : byte_count = 12'h001;
        4'b1000 : byte_count = 12'h001;
        4'b0000 : byte_count = 12'h001;

      endcase

    end


    always @ (rd_be_o or req_addr_i) begin

      casex (rd_be_o[3:0])
      
        4'b0000 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxxx1 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxx10 : lower_addr = {req_addr_i[4:0], 2'b01};
        4'bx100 : lower_addr = {req_addr_i[4:0], 2'b10};
        4'b1000 : lower_addr = {req_addr_i[4:0], 2'b11};

      endcase

    end

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          req_compl_q <= 1'b0;

        end else begin 

          req_compl_q <= req_compl_i;

        end

    end

	
	wire [63:0] TLPData;
	wire [39:0] TLPHeader;
	wire [15:0] BufferCounter = TLPHeader[39:24];
	reg  [15:0] BufferCounter_prev;
	wire [15:0] TLPNumber = TLPHeader[23:8];
	wire [23:0] TLPAddress = {1'b0, 1'b0, TLPNumber[14:0], 7'b0}; //address relative to buffer = packet number x 128		

	wire TestMode2 = 1'd0;//CONFIG_REG_2[27];


	//reg read_tlp_data;
	wire read_tlp_data = (bmd_64_tx_state==`BMD_64_TX_MWR_QWN)&&(!trn_tdst_rdy_n)&&
                        (trn_tdst_dsc_n)&&(cur_mwr_dw_count!=1);
	wire read_tlp_header = (bmd_64_tx_state==`BMD_64_TX_MWR_QW1)&&(!trn_tdst_rdy_n)&&
                        (trn_tdst_dsc_n);
 
	//reg read_tlp_header;
	reg assert_interrupt;
	assign request_new_buffer_address = assert_interrupt;

	wire FIFO_DataWriteEnable, FIFO_HeaderWriteEnable;
	wire FIFO_empty, FIFO_full; //, FIFO_prog_empty, FIFO_prog_full;
	wire FIFO_Header_Valid;
	
   wire [63:0] tmp_data;
	wire [39:0] tmp_header;
	
   b8to64 b8to64_inst(
		.rst((!rst_n)|init_rst_i|(!mwr_start_i)), 
		.ADC1_in(ADC1), 
		.ADC2_in(ADC2), 
		.InputClock(ADCc), 
		.DoubleInputClock(ADCc_2x), 
		.TLPData(tmp_data), 
		.TLPHeader(tmp_header),
		.DataWriteEnable(FIFO_DataWriteEnable), 
		.HeaderWriteEnable(FIFO_HeaderWriteEnable),
		.OutputSignals(S_OUT), 
		.CONFIG_REG_1(CONFIG_REG_1), 
		.CONFIG_REG_2(CONFIG_REG_2),
		.BufferLengthTLPs(TLPMaxNumber));
  
  reg FIFO_DataWriteStop;

	assign DEBUG[0]=read_tlp_data; //N18
	assign DEBUG[1]=read_tlp_header; //R16
	assign DEBUG[2]=FIFO_DataWriteStop; //U18
 
  always @(posedge ADCc) begin
	if((!rst_n)|init_rst_i) begin
		FIFO_DataWriteStop<=0;
	end else begin
		if(FIFO_HeaderWriteEnable)
			FIFO_DataWriteStop<=FIFO_full; //block data writing for whole packet if fifo is full
	end
  end

	fifo_tlp_data fifo_data(
		.rst((!rst_n)|init_rst_i|(!mwr_start_i)), 
		.wr_clk(ADCc), 
		.rd_clk(clk), 
		.din(tmp_data), 
		.wr_en(FIFO_DataWriteEnable&(!FIFO_DataWriteStop)),
		.rd_en(read_tlp_data), 
		.dout(TLPData));	

	fifo_tlp_headers fifo_headers(
		.rst((!rst_n)|init_rst_i|(!mwr_start_i)), 
		.wr_clk(ADCc), 
		.rd_clk(clk), 
		.din(tmp_header), 
		.wr_en(FIFO_HeaderWriteEnable&(!FIFO_full)),
		.rd_en(read_tlp_header), 
		.dout(TLPHeader), 
		.full(FIFO_full), 
		.prog_empty(FIFO_empty),
		.valid(FIFO_Header_Valid)
		); 

	assign LED[0] = (bmd_64_tx_state==`BMD_64_TX_MWR_QW1); //V2
	assign LED[1] = (bmd_64_tx_state==`BMD_64_TX_MWR_QWN); //V3
	assign LED[2] = (bmd_64_tx_state==`BMD_64_TX_RST_STATE); 

   wire  [2:0]         mwr_func_num = (!mwr_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {TLPNumber[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {TLPNumber[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {TLPNumber[10:8]} : 3'b000) : 3'b000;


    BMD_INTR_CTRL BMD_INTR_CTRL  (

      .clk(clk),                                     // I
      .rst_n(rst_n),                                 // I

      .init_rst_i(init_rst_i),                       // I

      .mwr_done_i(assert_interrupt),      // I

      .msi_on(cfg_msi_enable_i),                     // I

      .cfg_interrupt_rdy_n_i(cfg_interrupt_rdy_n_i), // I
      .cfg_interrupt_assert_n_o(cfg_interrupt_assert_n_o), // O
      .cfg_interrupt_n_o(cfg_interrupt_n_o),        // O
      .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr) // I

    );


    always @ ( posedge clk ) begin

        if ((!rst_n)|init_rst_i) begin
		  
		    trn_td <= 0;
  		    trn_tsof_n        <= 1'b1;
          trn_teof_n        <= 1'b1;
          trn_tsrc_rdy_n    <= 1'b1;
          trn_tsrc_dsc_n    <= 1'b1;
          trn_trem_n        <= 8'b0;
 
          cur_mwr_dw_count  <= 0;

          compl_done_o      <= 1'b0;

 			 //read_tlp_data <= 0;
			 //read_tlp_header <= 0; 
			 assert_interrupt <= 0;
			 BufferCounter_prev <= 0;
          bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;
			 
        end else begin 


          case ( bmd_64_tx_state ) 

            `BMD_64_TX_RST_STATE : begin
				
				//read_tlp_data<=0;
				//read_tlp_header<=0;
				
				if(BufferCounter!=BufferCounter_prev) begin
					BufferCounter_prev<=BufferCounter;
					assert_interrupt <= 1;
				end 
				else if(assert_interrupt) begin
				 assert_interrupt <= 0;
				end    
				 
            compl_done_o       <= 1'b0;

              if (req_compl_q && 
                  !compl_done_o &&
                  !trn_tdst_rdy_n &&
                  trn_tdst_dsc_n) begin


                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_CPLD_FMT_TYPE, 
                                      {1'b0}, 
                                      req_tc_i, 
                                      {4'b0}, 
                                      req_td_i, 
                                      req_ep_i, 
                                      req_attr_i, 
                                      {2'b0}, 
                                      req_len_i,
                                      completer_id_i, 
                                      {3'b0}, 
                                      {1'b0}, 
                                      byte_count };
                trn_trem_n        <= 8'b0;

                bmd_64_tx_state   <= `BMD_64_TX_CPLD_QW1;

              end else if (mwr_start_i && 			// start write operation
									addr_valid &&           // if have valid buffer address
									FIFO_Header_Valid &&    //!FIFO_empty &&          // and FIFO has at least 1 TLP
									BufferCounter==BufferCounter_prev && //and not asserting interrupt right now
									!assert_interrupt &&
									!trn_tdst_rdy_n &&
                           trn_tdst_dsc_n &&
									cfg_bm_en)
				  begin

				 
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      {`BMD_64_MWR_FMT_TYPE}, 
                                      {1'b0}, 
                                      mwr_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mwr_relaxed_order_i, mwr_nosnoop_i},
                                      {2'b0}, 
                                      mwr_len_i[9:0],
                                      {completer_id_i[15:3], mwr_func_num}, 
                                      cfg_ext_tag_en_i ? BufferCounter[7:0] : {3'b0, BufferCounter[4:0]},
                                      (mwr_len_i[9:0] == 1'b1) ? 4'b0 : mwr_lbe_i,
                                      mwr_fbe_i};
                trn_trem_n        <= 8'b0;
                
                
					 bmd_64_tx_state   <= `BMD_64_TX_MWR_QW1;
                
                
              end else  begin

                if(!trn_tdst_rdy_n) begin

                  trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
                  trn_tsrc_rdy_n    <= 1'b1;
                  trn_tsrc_dsc_n    <= 1'b1;
                  trn_td            <= 64'b0;
                  trn_trem_n        <= 8'b0;


                end
 
                bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

              end

            end




            `BMD_64_TX_MWR_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin //start of TLP
                trn_tsof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
						
					 trn_td           <= {{mwr_addr_i + TLPAddress}, 8'hFF, TLPHeader[7:0], BufferCounter[15:0]};
					 //read_tlp_header  <= 1;
 					 cur_mwr_dw_count <= 31; 
					 trn_trem_n       <= 8'hFF;
					 bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;
              end else if (!trn_tdst_dsc_n) begin
                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;
              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QW1;
            end

 
            `BMD_64_TX_MWR_QWN : begin
				  //read_tlp_header <= 0;
              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsrc_rdy_n   <= 1'b0;

                if (cur_mwr_dw_count == 1) begin //last DW - end of TLP

						//read_tlp_data    <= 0;
                  trn_td           <= {TLPNumber[15:0], BufferCounter[15:0], 32'd0};
					   
                  trn_trem_n       <= 8'h0F;
                  trn_teof_n       <= 1'b0;
													
                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                end else begin	//content of TLP

                  trn_td           <= TestMode2?64'h00_01_02_03_04_05_06_07:TLPData;
						//read_tlp_data    <= 1;
					   trn_trem_n       <= 8'hFF;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 2; 
                  bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

                end

              end else if (!trn_tdst_dsc_n) begin

					 //read_tlp_data   	  <= 0;
                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else begin

					 //read_tlp_data      <= 0;
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QWN;
					 
				  end

            end






            `BMD_64_TX_CPLD_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { req_rid_i, 
                                      req_tag_i, 
                                      {1'b0}, 
                                      lower_addr,
                                      rd_data_i };
                trn_trem_n       <= 8'h00;
                compl_done_o     <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_QW1;

            end

            `BMD_64_TX_CPLD_WIT : begin

              if ( (!trn_tdst_rdy_n) || (!trn_tdst_dsc_n) ) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_tsrc_dsc_n   <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

            end

 
          endcase

        end

    end

endmodule // BMD_64_TX_ENGINE

