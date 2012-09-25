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
	output [1:0] OutputSignals;	// [0] - output optical pulse start signal, [1] - switcher output
	input [31:0] CONFIG_REG_1;	//input control data from PC
	input [31:0] CONFIG_REG_2;	//input control data from PC
	input [15:0] BufferLengthTLPs;
									
	reg [7:0] DataStorage_8b [7:0]; //temporary 8-bit ADC data storage
	reg [11:0] DataStorage_12b [5:0]; //temporary 12-bit ADC data storage

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
	//27 - testmode2
	wire ADC_type = CONFIG_REG_2[28];
	
	reg [7:0] TestCounter;
	
	assign OutputSignals[1] = AutoPolSwitching?SwitcherState:ManualPolState;

	wire ADC_AutoSelector = AutoADCSwitching?CounterOfPoints[0]:SelectedADC; //active ADC selector
	
	wire [7:0] ActiveADC_8b = ADC_AutoSelector ? ADC2_in[7:0] : ADC1_in[7:0];
	wire [11:0] ActiveADC_12b = ADC_AutoSelector ? ADC2_in[11:0] : ADC1_in[11:0];

	wire [63:0] DataOutput_8b = {DataStorage_8b[0], DataStorage_8b[1], DataStorage_8b[2], DataStorage_8b[3], 
									     DataStorage_8b[4], DataStorage_8b[5], DataStorage_8b[6], DataStorage_8b[7]};

	wire [63:0] DataOutput_12b = {DataStorage_12b[0], DataStorage_12b[1], DataStorage_12b[2], 
											DataStorage_12b[3], DataStorage_12b[4], DataStorage_12b[5], 4'd0};

	wire [2:0] PointCounterTop = ADC_type ? 3'd4 : 3'd7;

	assign TLPData = ADC_type ? DataOutput_12b : DataOutput_8b;
		
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
			else if(CounterOfOctets>PulseOffset+PulseWidth)
					StartPulseState <= 0; //finish sync pulse
		end
	end

	
endmodule