

else if(testname == "pio_writeReadBack_test0")
begin

    // This test performs a 32 bit write to a 32 bit Memory space and performs a read back

    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_INIT;

//--------------------------------------------------------------------------
// Event : Testing BARs
//--------------------------------------------------------------------------

	for (ii = 0; ii <= 6; ii = ii + 1) begin
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) // bar is enabled
               case(BAR_INIT_P_BAR_ENABLED[ii])
		   2'b01 : // IO SPACE
			begin

		          $display("[%t] : Transmitting TLPs to IO Space BAR %x", $realtime, ii);

			  //--------------------------------------------------------------------------
			  // Event : IO Write bit TLP
			  //--------------------------------------------------------------------------



			  TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'hF, 32'hdead_beef);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  //--------------------------------------------------------------------------
			  // Event : IO Read bit TLP
			  //--------------------------------------------------------------------------


                          P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value
                          fork
			     TSK_TX_IO_READ(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (P_READ_DATA != 32'hdead_beef) 
                             begin
                               $display("[%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x", $realtime,
                                    32'hdead_beef, P_READ_DATA);
                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received", $realtime, P_READ_DATA);
                             end
            

                          TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

			
		        end

		   2'b10 : // MEM 32 SPACE
			begin


		          $display("[%t] : Transmitting TLPs to Memory 32 Space BAR %x", $realtime, ii);

			  //--------------------------------------------------------------------------
			  // Event : Memory Write 32 bit TLP
			  //--------------------------------------------------------------------------

                          DATA_STORE[0] = 8'h04;
                          DATA_STORE[1] = 8'h03;
                          DATA_STORE[2] = 8'h02;
                          DATA_STORE[3] = 8'h01;

			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0]+8'h10, 4'h0, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  //--------------------------------------------------------------------------
			  // Event : Memory Read 32 bit TLP
			  //--------------------------------------------------------------------------


                         P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value
                          fork
			     TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0]+8'h10, 4'h0, 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (P_READ_DATA != {DATA_STORE[3], DATA_STORE[2], DATA_STORE[1],
                                      DATA_STORE[0] })
                             begin
                               $display("[%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x", $realtime,
                                    {DATA_STORE[3],DATA_STORE[2],DATA_STORE[1],DATA_STORE[0]}, P_READ_DATA);

                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received", $realtime, P_READ_DATA);
                             end


                          TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

		     end
		2'b11 : // MEM 64 SPACE
		     begin


		          $display("[%t] : Transmitting TLPs to Memory 64 Space BAR %x", $realtime, ii);

			  //--------------------------------------------------------------------------
			  // Event : Memory Write 64 bit TLP
			  //--------------------------------------------------------------------------

                          DATA_STORE[0] = 8'h64;
                          DATA_STORE[1] = 8'h63;
                          DATA_STORE[2] = 8'h62;
                          DATA_STORE[3] = 8'h61;

			  TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                         BAR_INIT_P_BAR[ii][31:0]+8'h20}, 4'h0, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;			   

			  //--------------------------------------------------------------------------
			  // Event : Memory Read 64 bit TLP
			  //--------------------------------------------------------------------------
				

                          P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value 
                          fork
			     TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                           BAR_INIT_P_BAR[ii][31:0]+8'h20}, 4'h0, 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (P_READ_DATA != {DATA_STORE[3], DATA_STORE[2], DATA_STORE[1],
                                      DATA_STORE[0] }) 
                             begin
                               $display("[%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x", $realtime,
                                    {DATA_STORE[3],DATA_STORE[2],DATA_STORE[1],DATA_STORE[0]}, P_READ_DATA);
 
                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received", $realtime, P_READ_DATA);
                             end

                          
                          TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

		   
        	     end
		default : $display("Error case in usrapp_tx\n");
	    endcase         

	 end


    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    $finish;
end


else if(testname == "pio_testByteEnables_test0")
begin


    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_INIT;


	for (ii = 0; ii <= 6; ii = ii + 1) begin
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) // bar is enabled
               case(BAR_INIT_P_BAR_ENABLED[ii])
		   2'b01 : // IO SPACE
			begin			   


                          $display("[%t] : Transmission to IO Space BAR %x", $realtime, ii);

                          data = 32'h01FFFFFF;
                          $display("[%t] : IOWRITE, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'h8, data);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;


                          data = 32'hFF23FFFF;
                          $display("[%t] : IOWRITE, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'h4, data);
      
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          
                          data = 32'hFFFF45FF;
                          $display("[%t] : IOWRITE, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'h2, data);
              
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;
                                                   

                          data = 32'hFFFFFF67;
                          $display("[%t] : IOWRITE, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);   
                          TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'h1, data);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;
                                                                                          
                          P_READ_DATA = 32'hFFFF_FFFF;
                          fork
                             TSK_TX_IO_READ(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'hF);
                             TSK_WAIT_FOR_READ_DATA;
                          join
                          $display("[%t] : IOREAD, Address = %x, Read Data %x", $realtime, BAR_INIT_P_BAR[ii][31:0], P_READ_DATA);
                          DEFAULT_TAG = DEFAULT_TAG + 1;
            
                          if  (P_READ_DATA != 32'h01234567)

                          begin
                            $display("[%t] : Test FAILED --- Error: Pattern Mismatch, Address = %x, Write Data 01234567 != Read Data %x",
                                    $realtime, BAR_INIT_P_BAR[ii][31:0]+2, P_READ_DATA);

 
                          end
 
                          $display("[%t] : TEST PASSED --- IO test for pio_testByteEnables_test1", $realtime);




		        end

		   2'b10 : // MEM 32 SPACE
			begin

                          $display("[%t] : Transmission to Mem 32 Space BAR %x", $realtime, ii);
                          data = 32'h01FFFFFF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24];
                          $display("[%t] : MEMWRITE32, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);       
                          TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1,
                                               BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'h8, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;       


                           data = 32'hFF23FFFF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24];
                          $display("[%t] : MEMWRITE32, Address = %x, Write Data %x", 
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1,
                                               BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'h4, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          
                          data = 32'hFFFF45FF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24]; 
                          $display("[%t] : MEMWRITE32, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1,
                                               BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'h2, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          
                          data = 32'hFFFFFF67;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24]; 
                          $display("[%t] : MEMWRITE32, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1,
                                               BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'h1, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          P_READ_DATA = 32'hFFFF_FFFF;
                          fork
                             TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1,
                                      BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'hF);
                             TSK_WAIT_FOR_READ_DATA;
                          join
                          $display("[%t] : MEMREAD32, Address = %x, Read Data %x", $realtime, BAR_INIT_P_BAR[ii][31:0], P_READ_DATA);
                          DEFAULT_TAG = DEFAULT_TAG + 1;                        

                          if  (P_READ_DATA != 32'h01234567)

                          begin
                            $display("[%t] : Test FAILED --- Error: Pattern Mismatch, Address = %x, Write Data 01234567 != Read Data %x",
                                    $realtime, BAR_INIT_P_BAR[ii][31:0]+2, P_READ_DATA);

                          end

                          $display("[%t] : TEST PASSED --- Mem 32 for pio_memTestByteEnables_test1", $realtime);

		        end
		   2'b11 : // MEM 64 SPACE
		        begin
		          
                          $display("[%t] : Transmission to Mem 64 Space BAR %x", $realtime, ii);
                          data = 32'h01FFFFFF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24];
                          $display("[%t] : MEMWRITE64, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                         BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'h8, 1'b0);

                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;


                          data = 32'hFF23FFFF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24]; 
                          $display("[%t] : MEMWRITE64, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                         BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'h4, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1;
                          
                          
                          data = 32'hFFFF45FF;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24];
                          $display("[%t] : MEMWRITE64, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);       
                          TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                         BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'h2, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          
                          data = 32'hFFFFFF67;
                          DATA_STORE[0] = data[7:0];
                          DATA_STORE[1] = data[15:8];
                          DATA_STORE[2] = data[23:16];
                          DATA_STORE[3] = data[31:24]; 
                          $display("[%t] : MEMWRITE64, Address = %x, Write Data %x",
                                     $realtime, BAR_INIT_P_BAR[ii][31:0], data);
                          TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                         BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'h1, 1'b0);
                          TSK_TX_CLK_EAT(10);
                          DEFAULT_TAG = DEFAULT_TAG + 1; 

                          P_READ_DATA = 32'hFFFF_FFFF;
                          fork
                             TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0],
			                           BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'hF);
                             TSK_WAIT_FOR_READ_DATA;
                          join
                          $display("[%t] : MEMREAD64, Address = %x, Read Data %x", $realtime, BAR_INIT_P_BAR[ii][31:0], P_READ_DATA);
                          DEFAULT_TAG = DEFAULT_TAG + 1;                        

                          if  (P_READ_DATA != 32'h01234567)

                          begin
                            $display("[%t] : Test FAILED --- Error: Pattern Mismatch, Address = %x, Write Data 01234567 != Read Data %x",
                                    $realtime, BAR_INIT_P_BAR[ii][31:0]+2, P_READ_DATA);

                          end

                          $display("[%t] : TEST PASSED --- Mem 64 for pio_memTestByteEnables_test1", $realtime);
		          

        	        end
		default : $display("Error case in usrapp_tx\n");
	    endcase         

	 end

    
    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    $finish;
end


else if(testname == "pio_memTestDataBus")
begin

    // This test will verify the data bus connections for the PIO designs block RAMS.
    // This memory test should be run prior to any other memory tests.
   
    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_INIT;


   verbose = 1;

	for (ii = 0; ii <= 6; ii = ii + 1) begin
	   
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) begin // bar is enabled
        

        
      $display("[%t] : Performing Memory data test to BAR %x of PIO design", $realtime, ii);

      TSK_MEM_TEST_DATA_BUS(ii);
        
      $display("[%t] : Test PASSED --- Finished Data Bus test to BAR %x", $realtime, ii);
	       $finish; // comment this line in order to run the Mem test to each of the 4 Block RAMS

	    end

	 end

    
    $finish;
end


else if(testname == "pio_memTestAddrBus")
begin

    // This test will verify the address bus connections for the PIO designs block RAMS.
    // This memory test should be run after the data bus test.

    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;
    
    TSK_BAR_INIT;


   PIO_MAX_MEMORY = 16; // Comment out this line in order to test the entire 8Kbyte memory space

                        // which will make this a long test to run.

	for (ii = 0; ii <= 6; ii = ii + 1) begin
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) begin // bar is enabled
     

     
          $display("[%t] : Performing Memory address test to BAR %x of PIO design", $realtime, ii);
     
          TSK_MEM_TEST_ADDR_BUS(ii, PIO_MAX_MEMORY);
     
          $display("[%t] : Address Test PASSED to BAR %x", $realtime, ii);
     

     
      end
	          
	 end

    $display("[%t] : Test PASSED --- Finished pio_memTestAddrBus", $realtime);
    $finish;
end



else if(testname == "pio_memTestDevice")
begin

    // This test will verify memory bit for the block RAMs of the PIO designs block RAMS.
    // This memory test should be run only after the address memory test.
   
    TSK_SIMULATION_TIMEOUT(80000);

    TSK_SYSTEM_INITIALIZATION;
    
    TSK_BAR_INIT;

    PIO_MAX_MEMORY = 8;  // Comment out this line in order to test the entire 8Kbyte memory space
                         // which will make this a VERY long test to run.

	for (ii = 0; ii <= 6; ii = ii + 1) begin

	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) begin // bar is enabled
                      

                    $display("[%t] : Performing Memory device test to BAR %x of PIO design", $realtime, ii);
                    TSK_MEM_TEST_DEVICE(ii, PIO_MAX_MEMORY);
                    $display("[%t] : Device Test PASSED for BAR %x", $realtime,ii);
	                  				
	    end
  

	 end

    $display("[%t] : Test PASSED --- Finished pio_memTestDevice", $realtime);
    $finish;


end



else if(testname == "pio_readConfigReg_test0")
begin

    // This test will verify memory bit for the block RAMs of the PIO designs block RAMS.
    // This memory test should be run only after the address memory test.

    TSK_SIMULATION_TIMEOUT(80000);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_INIT;

    TSK_TX_READBACK_CONFIG; // read config registers via trn tx interface


end



else if(testname == "pio_tlp_test0")
begin
    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;
    
    TSK_BAR_INIT;

//--------------------------------------------------------------------------
//        Testing each BAR specific to its type (Mem32/IO/Mem64). Note
//         that the burst Mem32 and Completion TLPs will be received
//         by the PIO design passing through the core but will be discared. Only
//         1DW Mem32, IO, and mem64 TLPs will be successfully processed. This
//         test is for illustrative purposes and shows how the user can perform
//         various TLP transactions.
//--------------------------------------------------------------------------


	for (ii = 0; ii <= 6; ii = ii + 1) begin
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) // bar is enabled
               case(BAR_INIT_P_BAR_ENABLED[ii])
		   2'b01 : // IO SPACE
			begin
			   
			  $display("[%t] : Transmitting TLPs to IO 32 Space BAR %x", $realtime, ii);


                         //--------------------------------------------------------------------------
			  // Event : IO Write TLP
			  //--------------------------------------------------------------------------

			  TSK_TX_IO_WRITE(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'hF, 32'hdead_beef);
			  TSK_TX_CLK_EAT(1000);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  //--------------------------------------------------------------------------
			  // Event : IO Read TLP
			  //--------------------------------------------------------------------------

			  TSK_TX_IO_READ(DEFAULT_TAG, BAR_INIT_P_BAR[ii][31:0], 4'hF);
			  TSK_TX_CLK_EAT(100);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			 

		        end

		   2'b10 : // MEM 32 SPACE
			begin

			   
		          $display("[%t] : Transmitting TLPs to Memory 32 Space BAR %x", $realtime, ii);


			  //--------------------------------------------------------------------------
			  // Event : Memory Write 32 bit TLPs
			  //--------------------------------------------------------------------------


			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd16, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd32, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd64, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;

			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd128, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(1000);
			  DEFAULT_TAG = DEFAULT_TAG + 1;
			  

			  //--------------------------------------------------------------------------
			  // Event : Memory Read 32 bit TLPs
			  //--------------------------------------------------------------------------


			  TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0], 4'h0, 4'hF);
        		  TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

			  TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd16, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF);
        		  TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

        		  TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd32, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF);
        		  TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

        		  TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd64, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF);
        		  TSK_TX_CLK_EAT(10);
        		  DEFAULT_TAG = DEFAULT_TAG + 1;

        		  TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd128, BAR_INIT_P_BAR[ii][31:0], 4'hF, 4'hF);
        		  TSK_TX_CLK_EAT(1000);
       			  DEFAULT_TAG = DEFAULT_TAG + 1;
       				

       				
		     end
		2'b11 : // MEM 64 SPACE 			
		     begin

		       $display("[%t] : Transmitting TLPs to Memory 64 Space BAR %x", $realtime, ii);



		       //--------------------------------------------------------------------------
		       // Event : Memory Write 64 bit TLPs
		       //--------------------------------------------------------------------------

		       TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'hF, 1'b0);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd16, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF, 1'b0);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd32, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF, 1'b0);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd64, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF, 1'b0);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_WRITE_64(DEFAULT_TAG, DEFAULT_TC, 10'd128, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF, 1'b0);
		       TSK_TX_CLK_EAT(1000);
		       DEFAULT_TAG = DEFAULT_TAG + 1;


		       //--------------------------------------------------------------------------
		       // Event : Memory Read 64 bit TLPs
		       //--------------------------------------------------------------------------

         	       TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd1, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'h0, 4'hF);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd16, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd32, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd64, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF);
		       TSK_TX_CLK_EAT(10);
		       DEFAULT_TAG = DEFAULT_TAG + 1;

		       TSK_TX_MEMORY_READ_64(DEFAULT_TAG, DEFAULT_TC, 10'd128, {BAR_INIT_P_BAR[ii+1][31:0], BAR_INIT_P_BAR[ii][31:0]}, 4'hF, 4'hF);
		       TSK_TX_CLK_EAT(1000);
		       DEFAULT_TAG = DEFAULT_TAG + 1;


			   
        	     end
		default : $display("Error case in usrapp_tx\n");
	    endcase
	          
	 end


	$display("[%t] : Transmitting Completion TLPs", $realtime);


    //--------------------------------------------------------------------------
    // Event # 13: Completion TLP
    //--------------------------------------------------------------------------

    $display("[%t] : Sending PCI-Express COMPLETION TLPs", $realtime);

    TSK_TX_COMPLETION(DEFAULT_TAG, DEFAULT_TC, 10'd6, 3'h0);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(10);

    //--------------------------------------------------------------------------
    // Event # 14: Completion with Data TLPs
    //--------------------------------------------------------------------------

    TSK_TX_COMPLETION_DATA(DEFAULT_TAG, DEFAULT_TC, 2, 12'hF, 7'b011_0101, 3'h0, 1'b0);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(10);

    TSK_TX_COMPLETION_DATA(DEFAULT_TAG, DEFAULT_TC, 16, 12'hF, 7'b011_0101, 3'h0, 1'b0);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(10);

    TSK_TX_COMPLETION_DATA(DEFAULT_TAG, DEFAULT_TC, 32, 12'hF, 7'b011_0101, 3'h0, 1'b0);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(10);

    TSK_TX_COMPLETION_DATA(DEFAULT_TAG, DEFAULT_TC, 5, 12'hF, 7'b011_0101, 3'h0, 1'b0);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(10);

    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    $finish;
end

else if(testname == "pio_timeoutFailureExpected")
begin

    // This test performs a 32 bit write to an illegal 32 bit Memory space address and performs a read back
    // The task TSK_WAIT_FOR_READ_DATA should time out.

    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_INIT;

//--------------------------------------------------------------------------
// Event : Testing Mem32 BARs
//--------------------------------------------------------------------------


	for (ii = 0; ii <= 6; ii = ii + 1) begin 
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) // bar is enabled
               case(BAR_INIT_P_BAR_ENABLED[ii])
		   2'b01 : // IO SPACE
			begin

			  $display("[%t] : NOTHING: to IO 32 Space BAR %x", $realtime, ii);
			
		        end
			   
		   2'b10 : // MEM 32 SPACE
			begin

			  cpld_to_finish = 0; // Turn off TSK_WAIT_FOR_READ_DATA's finish on timeout default mechanism
			  

		          $display("[%t] : Transmitting TLPs to Memory 32 Space BAR %x", $realtime, ii);

			  //--------------------------------------------------------------------------
			  // Event : Memory Write 32 bit TLP
			  //--------------------------------------------------------------------------

                          DATA_STORE[0] = 8'h04;
                          DATA_STORE[1] = 8'h03;
                          DATA_STORE[2] = 8'h02;
                          DATA_STORE[3] = 8'h01;
                          P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value
			  // Note that 32'h8000_0000 will most likely be unused memory space
			  TSK_TX_MEMORY_WRITE_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, 32'h8000_0000, 4'h0, 4'hF, 1'b0);
			  TSK_TX_CLK_EAT(10);
			  DEFAULT_TAG = DEFAULT_TAG + 1;			   

			  //--------------------------------------------------------------------------
			  // Event : Memory Read 32 bit TLP
			  //--------------------------------------------------------------------------

                          fork
			     TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, 32'h8000_0000, 4'h0, 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
                          join
                          if (cpld_to == 1) $display("[%t] : TEST PASSED --- Test correctly timed out. CPLD not received", $realtime);
                          else $display("[%t] : TEST FAILED --- CPLD received", $realtime);
                          $finish; 

                          

		     end
		2'b11 : // MEM 64 SPACE
		     begin

		       $display("[%t] : NOTHING: to Memory 64 Space BAR %x", $realtime, ii);

		   
        	     end
		default : $display("Error case in usrapp_tx\n");
	    endcase
	          
	 end


    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    $finish;
end


else if(testname == "pio_barRange_Test0")
begin

    // This test will verify the bar range checking ability of the first Mem32 space (not EROM)
    // The first read is valid. The second read is not.

    TSK_SIMULATION_TIMEOUT(10050);

    TSK_SYSTEM_INITIALIZATION;

    TSK_BAR_SCAN;   

    TSK_BUILD_PCIE_MAP; // build the map to determine which spaces are enabled to use in range increasing below
        
    TSK_DISPLAY_PCIE_MAP;
    

	for (ii = 0; ii <= 6; ii = ii + 1) begin  // should go from 0 to 6
	    if (BAR_INIT_P_BAR_ENABLED[ii] > 2'b00) // bar is enabled
               case(BAR_INIT_P_BAR_ENABLED[ii])
		   2'b01 : // IO SPACE
			begin

		        
			   
// future impl. shift over the range to the left one making sure to maintain the io bit

		        end

		   2'b10 : // MEM 32 SPACE
			begin
			

			    temp_register = BAR_INIT_P_BAR_RANGE[ii];
			    // Make the range twice as large so that there will be a hole in the memory map.

			   
// shift over the range to the left one making sure to maintain the prefetchable bit
			   
// and the erom enable bit for ii==6
			   
// for now dont worry about erom
			   
// double the size of the range so that the next build map creates unaddressable

// Memory 32 space

if (ii != 6)

    BAR_INIT_P_BAR_RANGE[ii] = BAR_INIT_P_BAR_RANGE[ii] << 1; // not worrying about prefetch
                            else begin
                               $display("Warning: EROM is only Mem32 space enabled. Ending Simulation");
                               $finish;
                            end


                         // Reset parameters used for determining PCIE MAP
                          BAR_INIT_P_MEM64_HI_START =  32'h0000_0001; // hi 32 bit start of 64bit memory
                          BAR_INIT_P_MEM64_LO_START =  32'h0000_0000; // low 32 bit start of 64bit memory
                          BAR_INIT_P_MEM32_START =     33'h00000_0000; // start of 32bit memory
                          BAR_INIT_P_IO_START      =   33'h00000_0000; // start of 32bit io 
                          pio_check_design = 0; // needed to avoid error checks by testbench

                          TSK_BUILD_PCIE_MAP; // Rebuild PCIE MAP based on increased range
        
                          TSK_DISPLAY_PCIE_MAP;

                          TSK_BAR_PROGRAM;    // Program Chip

		          $display("[%t] : Transmitting TLPs to Memory 32 Space BAR %x", $realtime, ii);

                          temp_register = temp_register ^ BAR_INIT_P_BAR_RANGE[ii][31:0]; // attain the invalid offset
	                  
	                  P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value
			  // The following read should succeed with cpld
			  // This read is at the top of the BARs range
                          fork
			     TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0]+temp_register-4, 4'h0, 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
			  join

                         $display("[%t] : TEST PASSED --- CPLD received", $realtime);

                         

                         // The following read should not succeed with a cpld

                         cpld_to_finish = 0; // Turn off TSK_WAIT_FOR_READ_DATA's finish on timeout default mechanism

                         P_READ_DATA = 32'hffff_ffff; // make sure P_READ_DATA has known initial value 
                          fork
			     TSK_TX_MEMORY_READ_32(DEFAULT_TAG, DEFAULT_TC, 10'd1, BAR_INIT_P_BAR[ii][31:0]+temp_register, 4'h0, 4'hF);
        		     TSK_WAIT_FOR_READ_DATA;
                          join

                          if (cpld_to == 1) $display("[%t] : TEST PASSED --- Test correctly timed out. CPLD not received", $realtime);
                          else $display("[%t] : TEST FAILED --- CPLD received", $realtime);
                           


                       



                        $finish;    


                        
		     end
		   2'b11 : // MEM 64 SPACE 			
		     begin

                           // shift over the range to the left one making sure to maintain the 64 address bit



        	     end
		default : begin
		            $display("Error case in usrapp_tx\n");
		            $finish;
		          end
	    endcase
	          
	 end


end






