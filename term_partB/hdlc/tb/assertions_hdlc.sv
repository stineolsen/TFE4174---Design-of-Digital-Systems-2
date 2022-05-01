//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:  
// Date:    
//////////////////////////////////////////////////

/* The assertions_hdlc module is a test module containing the concurrent
   assertions. It is used by binding the signals of assertions_hdlc to the
   corresponding signals in the test_hdlc testbench. This is already done in
   bind_hdlc.sv 

   For this exercise you will write concurrent assertions for the Rx module:
   - Verify that Rx_FlagDetect is asserted two cycles after a flag is received
   - Verify that Rx_AbortSignal is asserted after receiving an abort flag
*/


module assertions_hdlc (
  output int   ErrCntAssertions,
  input  logic Clk,
  input  logic Rst,
  input  logic Rx,
  input  logic Rx_FlagDetect,
  input  logic Rx_ValidFrame,
  input  logic Rx_AbortDetect,
  input  logic Rx_AbortSignal,
  input  logic Rx_Overflow,
  input  logic Rx_WrBuff,
  input  logic Rx_FrameError,
  input  logic Rx_EoF,
  input  logic Rx_StartZeroDetect,
  input  logic Rx_StartFCS,
  input  logic Rx_StopFCS,
  input  logic Rx_NewByte,
  input  logic RxD,
  input  logic Rx_FCSerr,
  input  logic Rx_Ready,
  input  logic Rx_FCSen,
  input  logic Rx_RdBuff,
  input  logic Rx_Drop,
 
  input  logic [7:0] Rx_DataBuffOut,
  input  logic [7:0] Rx_Data,
  input  logic [7:0] Rx_FrameSize,

  input  logic Tx,
  input  logic Tx_NewByte,
  input  logic [7:0] Tx_Data,
  input  logic Tx_ValidFrame,
  input  logic Tx_AbortFrame,
  input  logic Tx_AbortedTrans,
  input  logic Tx_WrBuff,
  input  logic [7:0] Tx_FrameSize,
  input  logic [7:0] Tx_DataOutBuff,
  input  logic Tx_Enable,
  input  logic Tx_Full,
  input  logic Tx_DataAvail,
  input  logic Tx_Done
);

initial begin
  ErrCntAssertions  =  0;
end
//
//
//  /*******************************************
//   *  Verify correct Rx_FlagDetect behavior  *
//   *******************************************/
//
//  sequence Rx_flag; //Rx_flag should become 01111110
//    !Rx ##1  Rx [*6] ##1 !Rx;  
//  endsequence
//
//  // Check if flag sequence is detected
//  property RX_FlagDetect;
//    @(posedge Clk) Rx_flag |-> ##2 Rx_FlagDetect;
//  endproperty
//
//  RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
//    $display("PASS: Flag detect");
//  end else begin 
//    $error("Flag sequence did not generate FlagDetect"); 
//    ErrCntAssertions++; 
//  end
//
//  /********************************************
//   *  Verify correct Rx_AbortSignal behavior  *
//   ********************************************/
//
//  //If abort is detected during valid frame. then abort signal should go high
//  property RX_AbortSignal;
//    @(posedge Clk) (Rx_ValidFrame and Rx_AbortDetect) |=> Rx_AbortSignal;
//  endproperty
//
//  RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
//    $display("PASS: Abort signal");
//  end else begin 
//    $error("AbortSignal did not go high after AbortDetect during validframe"); 
//    ErrCntAssertions++; 
//  end
//
//
/**************************************************
* PART B *
***************************************************/
//sequences:


sequence Tx_Zero_Check; 
//possible patterns where we have 111110
  ( Tx_Data ==? 8'bxx111110) or
  ((Tx_Data ==? 8'bxxx11111) && ($past(Tx_Data, 8) ==? 8'b0xxxxxxx)) or
  ((Tx_Data ==? 8'bxxxx1111) && ($past(Tx_Data, 8) ==? 8'b10xxxxxx)) or
  ((Tx_Data ==? 8'bxxxxx111) && ($past(Tx_Data, 8) ==? 8'b110xxxxx)) or
  ((Tx_Data ==? 8'bxxxxxx11) && ($past(Tx_Data, 8) ==? 8'b1110xxxx)) or
  ((Tx_Data ==? 8'bxxxxxxx1) && ($past(Tx_Data, 8) ==? 8'b11110xxx)) or
  ( Tx_Data ==? 8'b111110xx) or
  ( Tx_Data ==? 8'bx111110x) or
  ( Tx_Data ==? 8'bxx111110);
endsequence

//Properties 

//1-4. Correct TX output according to written TX buffer
//done as immediate assertion


//5. Start and end of frame pattern generation (Start and end flag: 0111_1110)
property RX_FlagDetect;
  @(posedge Clk) !Rx ##1  Rx [*6] ##1 !Rx |->  ##2 Rx_FlagDetect;
endproperty

property TX_FlagGenerate;
	disable iff (!Rst) 
	@(posedge Clk) !Tx_AbortFrame ##2 $rose(Tx_ValidFrame) |-> ##[0:2] !Tx ##1 Tx[*6] ##1 !Tx;
endproperty 


//6. Zero insertion  
property TX_ZeroInsertion;
	disable iff (!Rst || !Tx_ValidFrame)
  @(posedge Clk)  $rose(Tx_NewByte) and Tx_Zero_Check |->  !Tx; 
endproperty

property RX_ZeroRemoval;
  disable iff (!Rst)
   @(posedge Clk) (!Rx ##1 Rx[*5] ##1 !Rx and Rx_ValidFrame [*6]) |-> ##[9:17] Rx_NewByte ##1 Rx_Data[*5];
endproperty


//7.Idle pattern generation and checking 
//generation
property TX_GenerateIdlePattern;
  disable iff(!Rst)
	@(posedge Clk) !Tx_ValidFrame and Tx_FrameSize==8'b0 and !Tx_AbortedTrans |-> Tx[*8];
endproperty

//Checking
property RX_CheckIdlePattern;
  disable iff (!Rst)
	@(posedge Clk) Rx[*8] |-> ##1 !Rx_FlagDetect;
endproperty


//8. Abort Pattern generation and checking
//generation 
property TX_GenerateAbortPattern; 
  disable iff (!Rst)
  @(posedge Clk) Tx_AbortFrame and Tx_ValidFrame |-> ##4 !Tx ##1 Tx [*7];
endproperty

//checking
property RX_CheckAbortPattern;
  disable iff (!Rst)
  @(posedge Clk) !Rx ##1 Rx[*7] |-> ##2 $rose(Rx_AbortDetect);
endproperty


//9.When aborting frame during transmission, Tx_AbortedTrans should be asserted.
property TX_TransmissionAbort;  
  disable iff (!Rst)
  @(posedge Clk)  Tx_AbortFrame && Tx_DataAvail ##1 $fell(Tx_AbortFrame) |=>  $rose(Tx_AbortedTrans);
endproperty


//10. Abort pattern detected during valid frame should generate Rx_AbortSignal.
property RX_AbortSignal;
  @(posedge Clk) (Rx_ValidFrame && Rx_AbortDetect) |=> Rx_AbortSignal;
endproperty


//11. CRC generation and Checking.



//12. When a whole RX frame has been received, check if end of frame is generated
property Rx_EndOfFile;
  disable iff(!Rst)
	@(posedge Clk) $fell(Rx_ValidFrame) |-> ##1 $rose(Rx_EoF);
endproperty


//13. When receiving more than 128 bytes, Rx_Overflow should be asserted.
property RX_Overflow;
  disable iff (!Rst || !Rx_ValidFrame)
  @(posedge Clk) $rose(Rx_ValidFrame) and ($rose(Rx_NewByte) [->129])  |=> $rose(Rx_Overflow);
endproperty


//14. Rx_FrameSize should equal the number of bytes received in a frame (max. 126 bytes =128
//bytes in buffer – 2 FCS bytes).
property FrameSizeNumOfBytes;
  int numBytes=0;
  disable iff(!Rst)
  @(posedge Clk) $rose(Rx_ValidFrame) and (##[7:9]$rose(Rx_NewByte),numBytes++)[*1:128] ##5 Rx_EoF |=> Rx_FrameSize == (numBytes-2);
endproperty


//15.Rx_Ready should indicate byte(s) in RX buffer is ready to be read.
property RX_Ready;
  disable iff(!Rst)
  @(posedge Clk) $rose(Rx_Ready) |-> !Rx_ValidFrame and $rose(Rx_EoF)
endproperty


//16. Non-byte aligned data or error in FCS checking should result in frame error.
//-------------------------------------does not work----------------------------------
property RX_FrameErrorCheck;
  disable iff (!Rst)
	@(posedge Clk) Rx_FCSen |=> $rose(Rx_FrameError);
endproperty

//17. Tx_Done should be asserted when the entire TX buffer has been read for transmission
property TX_TransmissionDone; 
  disable iff (!Rst)
  @(posedge Clk) $fell(Tx_DataAvail) |-> Tx_Done;
endproperty

//18. Tx_Full should be asserted after writing 126 or more bytes to the TX buffer (overflow).
property TX_Overflow;
  disable iff (!Rst )
  @(posedge Clk) $fell(Tx_Done) and ((Tx_WrBuff) [->126]) |-> $past(Tx_Full);
endproperty



//assertions:  	
RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
    $display("PASS: start and end flag detected");
  end else begin
    $error("start and end flag not detected");
    ErrCntAssertions++;
  end

TX_FlagGenerate_Assert : assert property (TX_FlagGenerate) begin
    $display("PASS: Start and end frame generated");
  end else begin
    $error("TX Flag sequence did not generate start and end frame");
    ErrCntAssertions++;
  end

TX_ZeroInsertion_Assert: assert property (TX_ZeroInsertion) begin
    $display("PASS: TX Insertion passed");
  end else begin
    $error("TX Insertion failed");
    ErrCntAssertions++;
  end

RX_ZeroRemoval_Assert: assert property (RX_ZeroRemoval) begin
    $display("PASS: RX zero removal passed");
  end else begin
    $error("RX zero removal failed");
    ErrCntAssertions++;
  end

TX_GenerateIdlePattern_Assert: assert property (TX_GenerateIdlePattern) begin
	  $display("PASS: Idle pattern generated");
  end else begin
	  $error("FAIL: Idle pattern not generated");
	  ErrCntAssertions++;
end

RX_CheckIdlePattern_Assert: assert property (RX_CheckIdlePattern) begin
	  $display("PASS: Idle pattern observed");
  end else begin
	  $error("FAIL: Idle pattern not observed");
	  ErrCntAssertions++;
end

RX_CheckAbortPattern_Assert: assert property (RX_CheckAbortPattern) begin
    $display("PASSED CheckAbortPattern: Abort pattern observed");
  end else begin
    $error("FAIL in CheckAbortPattern: Abort pattern not observed");
    ErrCntAssertions++;
end

TX_GenerateAbortPattern_Assert: assert property (TX_GenerateAbortPattern) begin
    $display("PASSED GenerateAbortPattern: Abort pattern generated");
  end else begin
    $error("FAIL in GenerateAbortPattern: Abort pattern not generated");
    ErrCntAssertions++;
end

TX_TransmissionAbort_Assert: assert property (TX_TransmissionAbort) begin
    $display("PASSED TransmissionAbort: Tx_AbortedTrans asserted");
  end else begin
    $error("FAIL TransmissionAbort: Tx_AbortedTrans not asserted");
    ErrCntAssertions++;
end

RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
    $display("PASS: Abort signal");
  end else begin
    $error("Abort signal did not go high after AbortDetect during validframe");
    ErrCntAssertions++;
end

//missing a few assertions - 10. 11

RX_EoF_Assert: assert property (Rx_EndOfFile) begin
    $display("PASS: RX End Of file is generated");
  end else begin
    $error("FAIL: RX End Of file is not generated");
    ErrCntAssertions++;
end

RX_Overflow_Assert: assert property (RX_Overflow) begin
    $display ("PASS: RX overflow asserted");
  end else begin
    $error("FAIL: RX overflow not asserted");
    ErrCntAssertions++;
end

FrameSizeNumOfBytes_Assert: assert property (FrameSizeNumOfBytes) begin
    $display("PASS FrameSizeNumOfBytes: Framesize is equal to number of bytes received");
  end else begin
    $error("FAIL FrameSizeNumOfBytes: Framesize is not equal to number of bytes received ");
	ErrCntAssertions++;
end

RX_Ready_Assert: assert property (RX_Ready) begin
    $display("PASS: Rx_Ready set: Buffer ready to be read");
  end else begin
    $error("FAIL: RX_Ready not set");
	  ErrCntAssertions++;
end

RX_FrameErrorCheck_Assert: assert property (RX_FrameErrorCheck) begin
    $display("PASS FrameErrorCheck: FrameError signal gone high");
  end else begin
    $error("FAIL FrameErrorCheck: FrameError signal not gone high");
    ErrCntAssertions++;
end

TX_TransmissionDone_Assert: assert property (TX_TransmissionDone) begin
    $display("PASS: TransmissionDone: Tx_Done asserted");
  end else begin
    $error("FAIL TransmissionDone: Tx_Done not asserted");
    ErrCntAssertions++;
end

TX_Overflow_Assert: assert property (TX_Overflow) begin
    $display("PASS: Overflow: Tx_Overflow asserted");
  end else begin
    $error("FAIL TransmissionDone: Tx_Overflow not asserted");
    ErrCntAssertions++;
end

endmodule
