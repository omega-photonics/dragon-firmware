module b8to64(
	rst,
	ADC1_in,
	ADC2_in,
	InputClock,
	DoubleInputClock,
	TLPData,
	TLPHeader,
	DataWriteEnable,
	HeaderWriteEnable,
	OutputSignals,
	CONFIG_REG_1,
	CONFIG_REG_2,
	BufferLengthTLPs
	);
	
	input rst;
	input [11:0] ADC1_in; 		//input data from ADC
	input [11:0] ADC2_in;			//input data from ADC

	input InputClock;					//input clock from ADC
	input DoubleInputClock;
	output [63:0] TLPData;  //output data for FIFO
	output [39:0] TLPHeader;
	output DataWriteEnable;				//output clock for FIFO
	output HeaderWriteEnable;
	output [3:0] OutputSignals;	// [0] - output optical pulse start signal, [1] - switcher output,
											// [2], [3] - phase mixing outputs
	input [31:0] CONFIG_REG_1;	//input control data from PC
	input [31:0] CONFIG_REG_2;	//input control data from PC
	input [15:0] BufferLengthTLPs;
									
	reg [7:0] DataStorage_8b [7:0]; //temporary 8-bit ADC data storage
	reg [11:0] DataStorage_12b [4:0]; //temporary 12-bit ADC data storage

	reg [2:0]  CounterOfPoints; // counts 0 to 7(4) - ADC samples for 8-byte message
	reg [12:0] CounterOfOctets; // up to 8192 octets of bytes in 1 frame
	reg [15:0] CounterOfFrames; 
	
	reg [15:0] TLPCounter; //counts tlps for 1 buffer
	reg [3:0]  DataForTLPCounter;
	reg [15:0] BufferCounter;
	
	reg DelayState; // 1 tick delay for noise cancelling, also used as frame end signal
	
	reg DoubleClockState;
	
	reg StartPulseState; // stores output [0] state
	assign OutputSignals[0] = StartPulseState;

	reg SwitcherState; // stores output [1] state
	
	wire [12:0] FrameLength = CONFIG_REG_1[12:0];  //defines frame length: up to 8189
	wire [6:0]  PulseWidth = CONFIG_REG_1[19:13]; //defines sync pulse duration: up to 127
		wire SelectedADC = CONFIG_REG_1[20];
	wire AutoADCSwitching = CONFIG_REG_1[21];
	wire HalfClockShiftEnable = CONFIG_REG_1[22];
	wire [8:0] PulseOffset = CONFIG_REG_1[31:23]; //defines sync pulse offset
		
	wire [23:0] FrameCountToSwitch = 32'd600;//CONFIG_REG_2[23:0];
	wire AutoPolSwitching = 1'd1;//CONFIG_REG_2[24];
	wire ManualPolState = 1'd0;//CONFIG_REG_2[25];
	wire TestMode = 1'd0;//CONFIG_REG_2[26];
	//27 - testmode2
	wire ADC_type = 1'd0;// CONFIG_REG_2[28];
	wire [31:0] PulseMask = CONFIG_REG_2[31:0];
	reg   [31:0] PulseMaskCurrent;
	
	reg [7:0] TestCounter;
	
	reg [0:0] SyncState;
	assign OutputSignals[1] = SyncState;
	//assign OutputSignals[1] = AutoPolSwitching?SwitcherState:ManualPolState;

	wire ADC_AutoSelector = AutoADCSwitching?CounterOfPoints[0]:SelectedADC; //active ADC selector
	
	wire [7:0] ActiveADC_8b = ADC_AutoSelector ? ADC2_in[7:0] : ADC1_in[7:0];
	wire [11:0] ActiveADC_12b = ADC_AutoSelector ? ADC2_in[11:0] : ADC1_in[11:0];

	wire [63:0] DataOutput_8b = {DataStorage_8b[0], DataStorage_8b[1], DataStorage_8b[2], DataStorage_8b[3], 
									     DataStorage_8b[4], DataStorage_8b[5], DataStorage_8b[6], DataStorage_8b[7]};

	wire [63:0] DataOutput_12b = {DataStorage_12b[0], DataStorage_12b[1], DataStorage_12b[2], 
											DataStorage_12b[3], DataStorage_12b[4], 4'd0};

	wire [2:0] PointCounterTop = ADC_type ? 3'd4 : 3'd7;

	assign TLPData = ADC_type ? DataOutput_12b : DataOutput_8b;
		
	reg [39:0] TLPHeader;
	reg DataWriteEnable;
	reg HeaderWriteEnable;
	
	reg [1:0] PhaseSwitchCounter; //counts 0-1-2 each frame
	reg [1:0] PhaseSwitchState;
	assign OutputSignals[2] = PhaseSwitchState[0];
	assign OutputSignals[3] = PhaseSwitchState[1];

	reg [20:0] CounterOfTicks; // used for start pulse

	wire SyncPulseCondition = HalfClockShiftEnable ? DoubleClockState : ~DoubleClockState;
	
	reg[20:0] PulseCounter;
	reg[6:0] PulseSubCounter;
	 	
	always @(posedge DoubleInputClock) begin
	
		if(rst) begin
			DoubleClockState<=0;
			StartPulseState<=0;			
			CounterOfPoints<=0;
			CounterOfOctets<=0;
			CounterOfTicks<=0;
			CounterOfFrames<=0;
			SwitcherState<=0;
			DelayState<=0;
			TLPHeader<=0;
			DataWriteEnable<=0;
			HeaderWriteEnable<=0;
			TLPCounter<=0;
			DataForTLPCounter<=0;
			BufferCounter<=0;
			TestCounter<=0;
			PhaseSwitchCounter<=0;
			
			PulseCounter<=0;
			PulseSubCounter<=0;
			
			PulseMaskCurrent <= 0;
			SyncState <= 0;
		end else begin
		
			if ( PulseCounter < 21'd032 && SyncPulseCondition)
			begin
				if ((PulseMaskCurrent & (32'd01 << PulseCounter)) === (32'd01 << PulseCounter))
					StartPulseState <= 1;	
				else
					StartPulseState <= 0;	
			end
			
			if ( PulseCounter >= 21'd032 && SyncPulseCondition)
			begin
				StartPulseState <= 0;
			end
			
			if (PulseSubCounter + 1 < PulseWidth && SyncPulseCondition)
			begin
				PulseSubCounter <= PulseSubCounter + 1;
			end
			
			if (PulseSubCounter + 1 >= PulseWidth && SyncPulseCondition)
			begin
				PulseCounter <= PulseCounter+1;
				PulseSubCounter <= 0;
			end
			
			//////////////////////////////////////////////////////////
			if (CounterOfTicks == 1 && SyncPulseCondition)
			begin
				SyncState <= 1;
			end
						
			if (CounterOfTicks == 256*PulseWidth && SyncPulseCondition)
			begin
				PhaseSwitchState <= 0;
				SyncState <= 0;
			end
			
			if (CounterOfTicks == PulseWidth + PulseOffset && SyncPulseCondition)
			begin
				if(PhaseSwitchCounter==2)
					PhaseSwitchCounter<=0;
				else
					PhaseSwitchCounter<=PhaseSwitchCounter+1;

				PhaseSwitchState <= PhaseSwitchCounter;
			end
			
			DoubleClockState <= ~DoubleClockState;

			if(DoubleClockState) begin

				CounterOfTicks<=CounterOfTicks+1;
				
				/*
				if(PulseSubCounter+1 >= PulseWidth)
				begin
						PulseCounter <= PulseCounter+1;
						PulseSubCounter <= 0;
				end
				else
				begin
					PulseSubCounter<=PulseSubCounter+1;
				end
				*/
				
				
				DataStorage_8b[CounterOfPoints] <= TestMode?TestCounter:ActiveADC_8b;
				DataStorage_12b[CounterOfPoints] <= TestMode?TestCounter:ActiveADC_12b;
				TestCounter<=TestCounter+1;
			
				if(CounterOfPoints>=PointCounterTop) begin	
			
					if(CounterOfOctets>=FrameLength) begin
						if(DelayState==0) begin
							DelayState<=1;
						end else begin
							DelayState <= 0;
							CounterOfOctets <= 0;
							CounterOfTicks<=0;
							PulseCounter<=0;
							PulseSubCounter<=0;
							PulseMaskCurrent<=PulseMask;
							/*
							if(PhaseSwitchCounter==2)
								PhaseSwitchCounter<=0;
							else
								PhaseSwitchCounter<=PhaseSwitchCounter+1;						
								*/
								
							if(CounterOfFrames>=FrameCountToSwitch) begin
								CounterOfFrames <= 0;
								//SwitcherState <= ~SwitcherState;
							end
							else
								CounterOfFrames <= CounterOfFrames+1;
								
						end
					end	
				
					if(DelayState==0) begin
						DataWriteEnable <= 1;

						
							if(DataForTLPCounter>=14) begin
							
								DataForTLPCounter<=0;
								if(TLPCounter>=BufferLengthTLPs) begin
									TLPCounter<=0;
									BufferCounter<=BufferCounter+1;
								end else
									TLPCounter<=TLPCounter+1;
								
								TLPHeader <= {BufferCounter[15:0], TLPCounter[15:0], 
													SelectedADC, HalfClockShiftEnable, SwitcherState, 5'b11111}; //5 bits reserved
								HeaderWriteEnable<=1;
								
							end 
							else begin
								DataForTLPCounter<=DataForTLPCounter+1;
								HeaderWriteEnable<=0;
							end
							
						CounterOfPoints <= 0;
						CounterOfOctets <= CounterOfOctets+1;
					end
									
				end
				
				else	begin
					CounterOfPoints <= CounterOfPoints+1;
					DataWriteEnable <= 0;
					HeaderWriteEnable <= 0;
				end
			end
		end
	end
	
	
endmodule