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
//-- Filename: BMD_EP_MEM.v
//--
//-- Description: Endpoint control and status registers
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module BMD_EP_MEM# (
 parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14


)
(
							 DacData, CONFIG_REG_1, CONFIG_REG_2,
                      clk,                   // I
                      rst_n,                 // I

                      cfg_cap_max_lnk_width, // I [5:0]
                      cfg_neg_max_lnk_width, // I [5:0]

                      cfg_cap_max_payload_size,  // I [2:0]
                      cfg_prg_max_payload_size,  // I [2:0]
                      cfg_max_rd_req_size,   // I [2:0]

                      a_i,                   // I [8:0]
                      wr_en_i,               // I 
                      rd_d_o,                // O [31:0]
                      wr_d_i,                // I [31:0]

                      init_rst_o,            // O

                      mrd_start_o,           // O
                      mrd_int_dis_o,         // O
                      mrd_done_o,            // O
                      mrd_addr_o,            // O [31:0]
                      mrd_len_o,             // O [31:0]
                      mrd_tlp_tc_o,          // O [2:0]
                      mrd_64b_en_o,          // O
                      mrd_phant_func_dis1_o,  // O
                      mrd_up_addr_o,         // O [7:0]
                      mrd_count_o,           // O [31:0]
                      mrd_relaxed_order_o,   // O
                      mrd_nosnoop_o,         // O
                      mrd_wrr_cnt_o,         // O [7:0]

                      mwr_start_o,           // O
                      mwr_int_dis_o,         // O 
                      mwr_done_i,            // I
                      mwr_addr_o,            // O [31:0]
							 mwr_addr_i,			// I [32:0]
                      addr_wr_enable_o,      // O 
							 addr_rd_enable_o,
                      mwr_len_o,             // O [31:0]
                      mwr_tlp_tc_o,          // O [2:0]
                      mwr_64b_en_o,          // O
                      mwr_phant_func_dis1_o,  // O
                      mwr_up_addr_o,         // O [7:0]
                      mwr_count_o,           // O [31:0]
                      mwr_data_o,            // O [31:0]
                      mwr_relaxed_order_o,   // O
                      mwr_nosnoop_o,         // O
                      mwr_wrr_cnt_o,         // O [7:0]

                      cpl_ur_found_i,        // I [7:0] 
                      cpl_ur_tag_i,          // I [7:0]

                      cpld_data_o,           // O [31:0]
                      cpld_found_i,          // I [31:0]
                      cpld_data_size_i,      // I [31:0]
                      cpld_malformed_i,      // I
                      cpld_data_err_i,       // I
                      cpl_streaming_o,       // O
                      rd_metering_o,         // O
                      cfg_interrupt_di,      // O
                      cfg_interrupt_do,      // I
                      cfg_interrupt_mmenable,   // I
                      cfg_interrupt_msienable,  // I
                      cfg_interrupt_legacyclr,  // O
`ifdef PCIE2_0
                      pl_directed_link_change,
                      pl_ltssm_state,
                      pl_directed_link_width,
                      pl_directed_link_speed,
                      pl_directed_link_auton,
                      pl_upstream_preemph_src,
                      pl_sel_link_width,
                      pl_sel_link_rate,
                      pl_link_gen2_capable,
                      pl_link_partner_gen2_supported,
                      pl_initial_link_width,
                      pl_link_upcfg_capable,
                      pl_lane_reversal_mode,
                      pl_width_change_err_i,
                      pl_speed_change_err_i,
                      clr_pl_width_change_err,
                      clr_pl_speed_change_err,
                      clear_directed_speed_change_i,

`endif
                      trn_rnp_ok_n_o,
                      trn_tstr_n_o
                      );

  	 output [31:0]     DacData;
  	 output [31:0]     CONFIG_REG_1;
  	 output [31:0]     CONFIG_REG_2;
    input             clk;
    input             rst_n;

    input [5:0]       cfg_cap_max_lnk_width;
    input [5:0]       cfg_neg_max_lnk_width;

    input [2:0]       cfg_cap_max_payload_size;
    input [2:0]       cfg_prg_max_payload_size;
    input [2:0]       cfg_max_rd_req_size;

    input [6:0]       a_i;
    input             wr_en_i;
    output [31:0]     rd_d_o;
    input  [31:0]     wr_d_i;

    // CSR bits

    output            init_rst_o;

    output            mrd_start_o;
    output            mrd_int_dis_o;
    output            mrd_done_o;
    output [31:0]     mrd_addr_o;
    output [31:0]     mrd_len_o;
    output [2:0]      mrd_tlp_tc_o;
    output            mrd_64b_en_o;
    output            mrd_phant_func_dis1_o;
    output [7:0]      mrd_up_addr_o;
    output [31:0]     mrd_count_o;
    output            mrd_relaxed_order_o;
    output            mrd_nosnoop_o;
    output [7:0]      mrd_wrr_cnt_o;

    output            mwr_start_o;
    output            mwr_int_dis_o;
    input             mwr_done_i;
    output [31:0]     mwr_addr_o;
	 input  [31:0]		 mwr_addr_i;
    output            addr_wr_enable_o;
    output            addr_rd_enable_o;
    output [31:0]     mwr_len_o;
    output [2:0]      mwr_tlp_tc_o;
    output            mwr_64b_en_o;
    output            mwr_phant_func_dis1_o;
    output [7:0]      mwr_up_addr_o;
    output [31:0]     mwr_count_o;
    output [31:0]     mwr_data_o;
    output            mwr_relaxed_order_o;
    output            mwr_nosnoop_o;
    output [7:0]      mwr_wrr_cnt_o;

    input  [7:0]      cpl_ur_found_i;
    input  [7:0]      cpl_ur_tag_i;

    output [31:0]     cpld_data_o;
    input  [31:0]     cpld_found_i;
    input  [31:0]     cpld_data_size_i;
    input             cpld_malformed_i;
    input             cpld_data_err_i;
    output            cpl_streaming_o;
    output            rd_metering_o;

    output            trn_rnp_ok_n_o;
    output            trn_tstr_n_o;
    output [7:0]      cfg_interrupt_di;
    input  [7:0]      cfg_interrupt_do;
    input  [2:0]      cfg_interrupt_mmenable;
    input             cfg_interrupt_msienable;
    output            cfg_interrupt_legacyclr;

`ifdef PCIE2_0

    output [1:0]      pl_directed_link_change;
    input  [5:0]      pl_ltssm_state;
    output [1:0]      pl_directed_link_width;
    output            pl_directed_link_speed;
    output            pl_directed_link_auton;
    output            pl_upstream_preemph_src;
    input  [1:0]      pl_sel_link_width;
    input             pl_sel_link_rate;
    input             pl_link_gen2_capable;
    input             pl_link_partner_gen2_supported;
    input  [2:0]      pl_initial_link_width;
    input             pl_link_upcfg_capable;
    input  [1:0]      pl_lane_reversal_mode;

    input             pl_width_change_err_i;
    input             pl_speed_change_err_i;
    output            clr_pl_width_change_err;
    output            clr_pl_speed_change_err;
    input             clear_directed_speed_change_i;

`endif


    // Local Regs

    reg [31:0]        DacDataReg;
	 assign DacData =  DacDataReg;

    reg [31:0]        CONFIG_REG_1_reg;
	 assign CONFIG_REG_1 = CONFIG_REG_1_reg;

    reg [31:0]        CONFIG_REG_2_reg;
	 assign CONFIG_REG_2 = CONFIG_REG_2_reg;
	 
    reg [31:0]        rd_d_o /* synthesis syn_direct_enable = 0 */; 

    reg               init_rst_o;

    reg               mrd_start_o;
    reg               mrd_int_dis_o;
    reg [31:0]        mrd_addr_o;
    reg [31:0]        mrd_len_o;
    reg [31:0]        mrd_count_o;
    reg [2:0]         mrd_tlp_tc_o;
    reg               mrd_64b_en_o;
    reg               mrd_phant_func_dis1_o;
    reg [7:0]         mrd_up_addr_o;
    reg               mrd_relaxed_order_o;
    reg               mrd_nosnoop_o;
    reg [7:0]         mrd_wrr_cnt_o;

    reg               mwr_start_o;
    reg               mwr_int_dis_o;
    reg [31:0]        mwr_addr_o;
    reg               addr_wr_enable_o;
    reg               addr_rd_enable_o;
    reg [31:0]        mwr_len_o;
    reg [31:0]        mwr_count_o;
    reg [31:0]        mwr_data_o;
    reg [2:0]         mwr_tlp_tc_o;
    reg               mwr_64b_en_o;
    reg               mwr_phant_func_dis1_o;
    reg [7:0]         mwr_up_addr_o;
    reg               mwr_relaxed_order_o;
    reg               mwr_nosnoop_o;
    reg [7:0]         mwr_wrr_cnt_o;

    reg [31:0]        mrd_perf;
    reg [31:0]        mwr_perf;
 
    reg [31:0]        mrd_perf_post;
    reg [31:0]        mwr_perf_post;
 
    
    reg               mrd_done_o;

    reg [31:0]        cpld_data_o;
    reg [20:0]        expect_cpld_data_size;  // 2 GB max
    reg [20:0]        cpld_data_size;         // 2 GB max
    reg               cpld_done;

    reg               cpl_streaming_o;
    reg               rd_metering_o;
    reg               trn_rnp_ok_n_o;
    reg               trn_tstr_n_o;

    reg [7:0]         INTDI;
    reg               LEGACYCLR;
   
`ifdef PCIE2_0

    reg [1:0]         pl_directed_link_change;
    reg [1:0]         pl_directed_link_width;
    wire              pl_directed_link_speed;
    reg [1:0]         pl_directed_link_speed_binary;
    reg               pl_directed_link_auton;
    reg               pl_upstream_preemph_src;
    reg               pl_width_change_err;
    reg               pl_speed_change_err;
    reg               clr_pl_width_change_err;
    reg               clr_pl_speed_change_err;
    wire [1:0]        pl_sel_link_rate_binary;

`endif  
   
    wire [7:0]        fpga_family;
    wire [3:0]        interface_type;
    wire [7:0]        version_number;


    assign version_number = 8'h16;
    assign interface_type = INTERFACE_TYPE;
    assign fpga_family = FPGA_FAMILY;

/*`ifdef BMD_64
    assign interface_type = 4'b0010;
`else // BMD_32
    assign interface_type = 4'b0001;
`endif // BMD_64

`ifdef VIRTEX2P 
    assign fpga_family = 8'h11;
`endif // VIRTEX2P 

`ifdef VIRTEX4FX
    assign fpga_family = 8'h12;
`endif // VIRTEX4FX

`ifdef PCIEBLK
    assign fpga_family = 8'h13;
`endif // PCIEBLK

`ifdef SPARTAN3
    assign fpga_family = 8'h18;
`endif // SPARTAN3

`ifdef SPARTAN3E
    assign fpga_family = 8'h28;
`endif // SPARTAN3E

`ifdef SPARTAN3A
    assign fpga_family = 8'h38;
`endif // SPARTAN3A

*/
assign cfg_interrupt_di[7:0] = INTDI[7:0];
assign cfg_interrupt_legacyclr = LEGACYCLR;
//assign cfg_interrupt_di = 8'haa;


`ifdef PCIE2_0

   assign pl_sel_link_rate_binary = (pl_sel_link_rate == 0) ? 2'b01 : 2'b10;
   assign pl_directed_link_speed = (pl_directed_link_speed_binary == 2'b01) ?
                                                0 : 1;
`endif

	wire [31:0] USR_ID;

	USR_ACCESS_VIRTEX5 USR_ACCESS_inst 
	(
		.DATA(USR_ID)
	);



    always @(posedge clk ) begin
    
        if ( !rst_n ) begin

          init_rst_o  <= 1'b0;
			 
			 DacDataReg <= 32'b10000000_10000000_10000000_10000000;
			 
			 CONFIG_REG_1_reg <= 32'b000000000_0_0_0_0010000_1111111111111;
			 
			 CONFIG_REG_2_reg <= 32'b00000000_000000100000000000000000;

          mrd_start_o <= 1'b0;
          mrd_int_dis_o <= 1'b0;
          mrd_addr_o  <= 32'b0;
          mrd_len_o   <= 32'b0;
          mrd_count_o <= 32'b0;
          mrd_tlp_tc_o <= 3'b0;
          mrd_64b_en_o <= 1'b0;
          mrd_up_addr_o <= 8'b0;
          mrd_relaxed_order_o <= 1'b0;
          mrd_nosnoop_o <= 1'b0;
          mrd_phant_func_dis1_o <= 1'b0;

          mwr_phant_func_dis1_o <= 1'b0;
          mwr_start_o <= 1'b0;
          mwr_int_dis_o <= 1'b0;
          mwr_addr_o  <= 32'b0;
          addr_wr_enable_o  <= 0;
          addr_rd_enable_o  <= 0;
          mwr_len_o   <= 32;   //packet size in dwords = 32
          mwr_count_o <= 32768; //default buffer size = 32768 packets = 4096kB
          mwr_data_o  <= 32'b0;
          mwr_tlp_tc_o <= 3'b0;
          mwr_64b_en_o <= 1'b0;
          mwr_up_addr_o <= 8'b0;
          mwr_relaxed_order_o <= 1'b0;
          mwr_nosnoop_o <= 1'b0;

          cpld_data_o <= 32'b0;
          cpl_streaming_o <= 1'b1;
          rd_metering_o <= 1'b0;
          trn_rnp_ok_n_o <= 1'b0;
          trn_tstr_n_o <= 1'b0;
          mwr_wrr_cnt_o <= 8'h08;
//          mrd_wrr_cnt_o <= 8'h08;

`ifdef PCIE2_0

          clr_pl_width_change_err <= 1'b0;
          clr_pl_speed_change_err <= 1'b0;
          pl_directed_link_change <= 2'h0;
          pl_directed_link_width  <= 2'h0;
          pl_directed_link_speed_binary  <= 2'b0; 
          pl_directed_link_auton  <= 1'b0;
          pl_upstream_preemph_src <= 1'b0;
          pl_width_change_err     <= 0;
          pl_speed_change_err     <= 0;

`endif          
          INTDI   <= 8'h00;
          LEGACYCLR  <=  1'b0;     

        end else begin

`ifdef PCIE2_0

         if (a_i[6:0] != 7'b010011)   // Reg#19
         begin
            pl_width_change_err <= pl_width_change_err_i;
            pl_speed_change_err <= pl_speed_change_err_i;
            pl_directed_link_change <=
                        clear_directed_speed_change_i ? 0 :    // 1
                        pl_directed_link_change;               // 0
         end

`endif



         // 08-0BH : Reg # 2
         // Queue/dequeue buffer
			if(a_i[6:0]==7'b0000010) begin
              if (wr_en_i) begin
                mwr_addr_o  <= wr_d_i;
					 addr_wr_enable_o <= 1;
					 addr_rd_enable_o <= 0;
				  end	else begin
					 rd_d_o <= mwr_addr_i;
					 addr_rd_enable_o <= 1;
					 addr_wr_enable_o <= 0;
				  end
			 end
			 else begin
				addr_wr_enable_o <= 0;
				addr_rd_enable_o <= 0;
			 end


          case (a_i[6:0])
        
            // 00-03H : Reg # 0 
            // Byte0[0]: Initiator Reset (RW) 0= no reset 1=reset.
            // Byte2[19:16]: Data Path Width
            // Byte3[31:24]: FPGA Family
            7'b0000000: begin
          
              if (wr_en_i)
                init_rst_o  <= wr_d_i[0];
        
              rd_d_o <= {fpga_family, {4'b0}, interface_type, version_number, {7'b0}, init_rst_o};
                           
            end

            // 04-07H :  Reg # 1
            // Byte0[0]: Memory Write Start (RW) 0=no start, 1=start
            7'b0000001: begin
              if (wr_en_i) begin
				    mwr_start_o  <= wr_d_i[0];
              end 

            end

            // 0C-0FH : Reg # 3
            // set DACs
            7'b0000011: begin
              if (wr_en_i)	
                DacDataReg <= wr_d_i;      
              rd_d_o <= DacDataReg;
					
				end

            // 10-13H : Reg # 4
            // CONFIG REG 1
            7'b0000100: begin
              if (wr_en_i)
 					 CONFIG_REG_1_reg[31:13] <= wr_d_i[18:0];  
				  rd_d_o <= CONFIG_REG_1_reg[31:13];              

            end


            // 14-17H : Reg # 5
            // CONFIG REG 2
            7'b000101: begin
              if (wr_en_i)
 					 CONFIG_REG_2_reg <= wr_d_i;      
				  rd_d_o <= CONFIG_REG_2_reg;              

            end

            // Reg # 6
            // count of TLP packets in buffer
            7'b000110: begin
              if (wr_en_i)
                mwr_count_o  <= wr_d_i;         
              rd_d_o <= mwr_count_o; 
				  
            end
 

            // Reg # 7
            // frame length
            7'b000111: begin

              if (wr_en_i) begin
                CONFIG_REG_1_reg[12:0] <= wr_d_i[12:0];
				  end              
              rd_d_o <= CONFIG_REG_1_reg[12:0]; 
            end
				
				//reg 8 - USR_ID
				7'b001000: begin
              rd_d_o <= USR_ID; 
				end

				//reg 9 - test
				7'b001001: begin
              rd_d_o <= 32'hAB_D0_FF_CE; 
				end
 
            // 50-7FH : Reserved
            default: begin

              //rd_d_o <= 32'b0;

            end

          endcase

        end

    end


 
endmodule

