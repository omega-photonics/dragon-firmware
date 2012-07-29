module b8to64(
	clk,
	rst,
	ADC1_in,
	ADC2_in,
	InputClock,
	DoubleInputClock,
	OutputData,
	OutputDataClock,
	OutputSignals,
	CONFIG_REG_1,
	CONFIG_REG_2
	);
	
	input clk;
	input rst;
	input [7:0] ADC1_in; 		//input data from ADC
	input [7:0] ADC2_in;			//input data from ADC
	input InputClock;					//input clock from ADC
	input DoubleInputClock;
	output [63:0] OutputData;  //output data for FIFO
	output OutputDataClock;				//output clock for FIFO
	output [1:0] OutputSignals;	// [0] - output optical pulse start signal, [1] - switcher output
	input [31:0] CONFIG_REG_1;	//input control data from PC
	input [31:0] CONFIG_REG_2;	//input control data from PC
									
	reg [7:0] DataStorage [5:0]; //temporary ADC data storage

	reg [2:0] CounterOfPoints; // counts 0 to 5 - data for single packet
	reg [12:0] CounterOfSextets; // up to 8192 sextets of bytes in 1 frame
	reg [23:0] CounterOfFrames; //
	
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
	assign OutputSignals[1] = AutoPolSwitching?SwitcherState:ManualPolState;

	wire ADC_AutoSelector = AutoADCSwitching?CounterOfPoints[0]:SelectedADC; //active ADC selector
	wire [7:0] ActiveADC = ADC_AutoSelector ? ADC2_in : ADC1_in;

	wire [63:0] OutputData =  {SelectedADC, HalfClockShiftEnable, SwitcherState, CounterOfSextets[12:0], DataStorage[5], DataStorage[4], DataStorage[3], DataStorage[2], DataStorage[1], DataStorage[0]};
	assign DATA64_out = OutputData;
	//assign OutputDataClock = ((CounterOfPoints==5)&(DelayState==0)); //positive edge on each 6 counts of CounterOfPoints
	reg OutputDataClock;
	
	
	always @(posedge InputClock) begin
		if(rst) begin
			CounterOfPoints<=0;
			CounterOfSextets<=0;
			CounterOfFrames<=0;
			SwitcherState<=0;
			DelayState<=0;
			OutputDataClock<=0;
		end else begin
			DataStorage[CounterOfPoints] = ActiveADC; //blocking!

			if(CounterOfPoints==5) begin			
				if(CounterOfSextets==FrameLength) begin
					if(DelayState==0) begin
						DelayState<=1;
					end else begin
						OutputDataClock<=1;
						CounterOfPoints <= 0;
						CounterOfSextets <= 0;
						DelayState <= 0;
						if(1+CounterOfFrames>=FrameCountToSwitch) begin
							CounterOfFrames <= 0;
							SwitcherState <= ~SwitcherState;
						end
						else
							CounterOfFrames <= CounterOfFrames+1;
					end
				end			
				else begin
					OutputDataClock<=1;
					CounterOfPoints <= 0;
					CounterOfSextets <= CounterOfSextets+1;
				end
				
			end
			
			else	begin
				CounterOfPoints <= CounterOfPoints+1;
				OutputDataClock <= 0;
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
			if(CounterOfSextets==PulseOffset && SyncPulseCondition) StartPulseState <= 1; //start sync pulse
			if(CounterOfSextets==PulseOffset+PulseWidth && SyncPulseCondition) StartPulseState <= 0; //finish sync pulse
		end
	end

	
endmodule