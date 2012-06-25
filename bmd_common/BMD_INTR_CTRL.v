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
//-- Filename: BMD_INTR_CTRL.v
//--
//-- Description: Endpoint Intrrupt Controller
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns


`define BMD_INTR_RST      3'b001
`define BMD_INTR_RD       3'b010
`define BMD_INTR_WR       3'b100

`define BMD_INTR_RD_RST   4'b0001
`define BMD_INTR_RD_ACT   4'b0010
`define BMD_INTR_RD_ACT2  4'b0100
`define BMD_INTR_RD_DUN   4'b1000

`define BMD_INTR_WR_RST   4'b0001
`define BMD_INTR_WR_ACT   4'b0010
`define BMD_INTR_WR_ACT2  4'b0100
`define BMD_INTR_WR_DUN   4'b1000

module BMD_INTR_CTRL (
                      clk,                   // I
                      rst_n,                 // I

                      init_rst_i,            // I

                      mrd_done_i,            // I
                      mwr_done_i,            // I

                      msi_on,                // I

                      cfg_interrupt_assert_n_o, // O
                      cfg_interrupt_rdy_n_i,    // I
                      cfg_interrupt_n_o,        // O
                      cfg_interrupt_legacyclr   // I
       
                      );

    input             clk;
    input             rst_n;

    input             init_rst_i;

    input             mrd_done_i;
    input             mwr_done_i;

    input             msi_on;

    output            cfg_interrupt_assert_n_o;
    input             cfg_interrupt_rdy_n_i;
    output            cfg_interrupt_n_o;
    input             cfg_interrupt_legacyclr;

    // Local Registers

    reg [3:0]         wr_intr_state;
    reg [3:0]         next_wr_intr_state;

    reg               wr_intr_n;
    reg               wr_intr_assert_n;

    wire              mwr_exp;

    parameter         Tcq = 1;

    assign cfg_interrupt_n_o = wr_intr_n;
    assign cfg_interrupt_assert_n_o = wr_intr_assert_n;


    //
    // Write Interrupt Control
    // 
    always @(wr_intr_state or mwr_done_i or cfg_interrupt_rdy_n_i or cfg_interrupt_legacyclr or msi_on) begin

      case (wr_intr_state)

        `BMD_INTR_WR_RST : begin
          if (mwr_done_i) begin
            wr_intr_n = 1'b0;
				next_wr_intr_state = `BMD_INTR_WR_ACT;
          end else begin
            wr_intr_n = 1'b1;
            next_wr_intr_state = `BMD_INTR_WR_RST;
          end
        end


        `BMD_INTR_WR_ACT : begin
          if (!cfg_interrupt_rdy_n_i) begin
            wr_intr_n = 1'b1;
            next_wr_intr_state = `BMD_INTR_WR_RST;
          end else begin
            wr_intr_n = 1'b0;
            next_wr_intr_state = `BMD_INTR_WR_ACT;
          end
        end        
      endcase

    end



	  always @(posedge clk ) begin
    
        if ( !rst_n ) begin

          wr_intr_state <= #(Tcq) `BMD_INTR_WR_RST;

        end else begin

          if (init_rst_i) begin

            wr_intr_state <= #(Tcq) `BMD_INTR_WR_RST;

          end else begin

            wr_intr_state <= #(Tcq) next_wr_intr_state;

          end

        end

    end

endmodule

