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
	input [7:0] ADC1_in; 		//input data from ADC
	input [7:0] ADC2_in;			//input data from ADC
	input InputClock;					//input clock from ADC
	input DoubleInputClock;
	output [63:0] TLPData;  //output data for FIFO
	output [39:0] TLPHeader;
	output DataWriteEnable;				//output clock for FIFO
	output HeaderWriteEnable;
	output [1:0] OutputSignals;	// [0] - output optical pulse start signal, [1] - switcher output
	input [31:0] CONFIG_REG_1;	//input control data from PC
	input [31:0] CONFIG_REG_2;	//input control data from PC
	input [15:0] BufferLengthTLPs;
									
	reg [7:0] DataStorage [7:0]; //temporary ADC data storage

	reg [2:0]  CounterOfPoints; // counts 0 to 7 - bytes for single packet
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
	
	wire [23:0] FrameCountToSwitch = CONFIG_REG_2[23:0];
	wire AutoPolSwitching = CONFIG_REG_2[24];
	wire ManualPolState = CONFIG_REG_2[25];
	wire TestMode = CONFIG_REG_2[26];
	reg [7:0] TestCounter;
	
	assign OutputSignals[1] = AutoPolSwitching?SwitcherState:ManualPolState;

	wire ADC_AutoSelector = AutoADCSwitching?CounterOfPoints[0]:SelectedADC; //active ADC selector
	wire [7:0] ActiveADC = ADC_AutoSelector ? ADC2_in : ADC1_in;

	//reg [63:0] TLPData;
	assign TLPData = {DataStorage[0], DataStorage[1], DataStorage[2], DataStorage[3], 
									 DataStorage[4], DataStorage[5], DataStorage[6], DataStorage[7]};
	reg [39:0] TLPHeader;
	reg DataWriteEnable;
	reg HeaderWriteEnable;
	
	
	always @(posedge InputClock) begin
		if(rst) begin
			CounterOfPoints<=0;
			CounterOfOctets<=0;
			CounterOfFrames<=0;
			SwitcherState<=0;
			DelayState<=0;
			DataWriteEnable<=0;
			HeaderWriteEnable<=0;
			TLPCounter<=0;
			DataForTLPCounter<=0;
			BufferCounter<=0;
			TestCounter<=0;
		end else begin
			DataStorage[CounterOfPoints] <= TestMode?TestCounter:ActiveADC;
			TestCounter<=TestCounter+1;

			if(CounterOfPoints==7) begin	
			
				if(CounterOfOctets>=FrameLength) begin
					if(DelayState==0) begin
						DelayState<=1;
					end else begin
						DelayState <= 0;
						CounterOfOctets <= 0;
						if(CounterOfFrames>=FrameCountToSwitch) begin
							CounterOfFrames <= 0;
							SwitcherState <= ~SwitcherState;
						end
						else
							CounterOfFrames <= CounterOfFrames+1;
					end
				end	
				
				if(DelayState==0) begin
					DataWriteEnable <= 1;
	//				TLPData <=  {DataStorage[0], DataStorage[1], DataStorage[2], DataStorage[3], 
		//							 DataStorage[4], DataStorage[5], DataStorage[6], DataStorage[7]};

					
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
	
	wire SyncPulseCondition = HalfClockShiftEnable ? DoubleClockState : ~DoubleClockState;

	always @(posedge DoubleInputClock) begin
		if(rst) begin
			DoubleClockState<=0;
			StartPulseState<=0;			
		end
		else begin
			DoubleClockState <= ~DoubleClockState;
			if(CounterOfOctets>=PulseOffset && 
				CounterOfOctets<=PulseOffset+PulseWidth &&
				SyncPulseCondition) 
					StartPulseState <= 1; //start sync pulse
			else  StartPulseState <= 0; //finish sync pulse
		end
	end

	
endmodule