//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author:   
// Date:  
//////////////////////////////////////////////////

/* testPr_hdlc contains the simulation and immediate assertion code of the
   testbench. 

   For this exercise you will write immediate assertions for the Rx module which
   should verify correct values in some of the Rx registers for:
   - Normal behavior
   - Buffer overflow 
   - Aborts

   HINT:
   - A ReadAddress() task is provided, and addresses are documentet in the 
     HDLC Module Design Description
*/

program testPr_hdlc(
  in_hdlc uin_hdlc
);
  
  int TbErrorCnt;

  /****************************************************************************
   *                                                                          *
   *                               Student code                               *
   *                                                                          *
   ****************************************************************************/

//coverage

covergroup receive_cg() @(posedge uin_hdlc.Clk);
Rx_ValidFrame: coverpoint uin_hdlc.Rx_ValidFrame{
  bins FrameValid = {1};
  bins FrameNotValid = {0};
}

Rx_EoF: coverpoint uin_hdlc.Rx_EoF{
  bins EndOfFile = {1};
  bins NotEndOfFile = {0};
}

// Rx_AbortSignal: coverpoint uin_hdlc.Rx_AbortSignal{
//   bins Abort = {0};
//   bins NotAbort {1};
// }

Rx_FrameError:coverpoint uin_hdlc.Rx_FrameError{
  bins FrameError = {1};
  bins NotFrameError = {0};
}

Rx_Data: coverpoint uin_hdlc.Rx_Data{
  bins Rx_Data[] = {[0:31]};
}

Rx_NewByte: coverpoint uin_hdlc.Rx_NewByte{
  bins NewByte = {1};
  bins NoNewByte = {0};
}

Rx_FlagDetect: coverpoint uin_hdlc.Rx_FlagDetect{
  bins FlagDetected = {1};
  bins FlagNotDetected = {0};
}

Rx_AbortDetect: coverpoint uin_hdlc.Rx_AbortDetect{
  bins AbortDetected = {1};
  bins AbortNotDetected= {0};
}

Rx_Ready: coverpoint uin_hdlc.Rx_Ready{
  bins Ready = {1};
  bins NotReady = {0};
}

Rx_FrameSize: coverpoint uin_hdlc.Rx_FrameSize{
  bins FrameSize[] = {[0:7]};
}

Rx_Overflow: coverpoint uin_hdlc.Rx_Overflow{
  bins Overflow = {1};
  bins NotOverflow = {0};
}

Rx_FCSen: coverpoint uin_hdlc.Rx_FCSen{
  bins Enabled = {1};
  bins NotEnabled = {0};
}
endgroup

receive_cg inst_receive_cg = new();


covergroup transmit_cg() @(posedge uin_hdlc.Clk);
Tx_ValidFrame: coverpoint uin_hdlc.Tx_ValidFrame{
  bins FrameValid = {1};
  bins FrameNotValid = {0};
}

Tx_AbortedTrans: coverpoint uin_hdlc.Tx_AbortedTrans{
  bins TransmissionAborted = {1};
  bins  TransmissionNotAborted = {0};
}

Tx_NewByte: coverpoint uin_hdlc.Tx_NewByte{
  bins NewByte = {1};
  bins  NoNewByte = {0};
}

Tx_Data: coverpoint uin_hdlc.Tx_Data{
  bins Tx_Data[] = {[0:7]};
}

Tx_Done: coverpoint uin_hdlc.Tx_Done{
  bins Done = {1};
  bins NotDone = {0};
}

Tx_Full: coverpoint uin_hdlc.Tx_Full{
  bins Full = {1};
  bins NotFull = {0};
}

Tx_DataAvail: coverpoint uin_hdlc.Tx_DataAvail{
  bins Available = {1};
  bins NotAvailable = {0};
}

Tx_FrameSize: coverpoint uin_hdlc.Tx_FrameSize{
  bins Tx_FrameSize[] = {[0:7]};
}

Tx_DataOutBuff: coverpoint uin_hdlc.Tx_DataOutBuff{
  bins Tx_DataOutBuff[] = {[0:7]};
}

Tx_WrBuff: coverpoint uin_hdlc.Tx_WrBuff{
  bins BufferWritten = {1};
  bins BufferNotWritten = {0};
}

Tx_AbortFrame: coverpoint uin_hdlc.Tx_AbortFrame{
  bins Aborted = {1};
  bins NotAborted = {0};
}

endgroup
transmit_cg inst_transmit_cg = new();

covergroup registerinterface_cg() @(posedge uin_hdlc.Clk);
  DataIn: coverpoint uin_hdlc.DataIn {
    bins DataIn[] = {[0:31]};
   }
  DataOut: coverpoint uin_hdlc.DataOut {
    bins DataOut[] = {[0:31]};
   }
  Address: coverpoint uin_hdlc.Address {
    //tx:
    bins Tx_SC = {0};
    bins Tx_Buff = {1};
    //rx:
    bins Rx_SC = {2};
    bins Rx_Buff = {3};
  }
endgroup

registerinterface_cg inst_registerinterface_cg = new();




  // VerifyAbortReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer is zero after abort.
  task VerifyAbortReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
	
	  ReadAddress('h02,ReadData); //Rx_SC address is 0x2
     
	
    //assert that rx_sc is correct value for abort, all RO bits except abort should be 0. We dont know what value the WO bits will have
    
    a_Correct_Val_0: assert ( ReadData[0]==0)
      $display("PASS: VerifyAbortReceive PASSED, Rx_Buff has no data ");
    else begin
      $display("FAIL: VerifyAbortReceive FAILED,  wrong value in ReadData: %h",ReadData);
      TbErrorCnt++;
    end
    
    a_Correct_Val_2: assert ( ReadData[2]==0)
      $display("PASS: VerifyAbortReceive PASSED, No frame error ");
    else begin
      $display("FAIL: VerifyAbortReceive FAILED,  wrong value in ReadData: %h",ReadData);
      TbErrorCnt++;
    end
    
    a_Correct_Val_3: assert (ReadData[3]==1)
      $display("PASS: VerifyAbortReceive PASSED, Abort signal asserted ");
    else begin
      $display("FAIL: VerifyAbortReceive FAILED,  wrong value in ReadData: %h",ReadData);
      TbErrorCnt++;
    end

    a_Correct_Val_4: assert (ReadData[4]==0)
      $display("PASS: VerifyAbortReceive PASSED, No overflow signal ");
    else begin
      $display("FAIL: VerifyAbortReceive FAILED,  wrong value in ReadData: %h",ReadData);
      TbErrorCnt++;
    end
    

    //assert that rx_buff is empty
    ReadAddress('h03,ReadData); //Rx_Buff address is 0x3

    a_DataBuf_zero: assert (ReadData=='b00000000)
      $display("PASS: VerifyAbortReceive PASSED, Rx_Buff is empty");
    else begin
      $display("FAIL: VerifyAbortReceive FAILED, Rx databuf is not zero: %h",ReadData);   
      TbErrorCnt++;
    end 

  endtask

  //VerifyDropReceive should verify correct value in the Rx status/control register
  //->that the Rx data buffer is zero after a frame is dropped
  task VerifyDropReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    
    WriteAddress('h02,'h02); //RX_SC addr is 0x2 and its value should be 0x2, since RX_DROP should be set
    ReadAddress('h03,ReadData);
      a_Drop_DataBuf_zero: assert (ReadData=='b00000000)
        $display("PASS: VerifyDropReceive PASSED, Rx_Buff is empty");
      else begin
        $display("FAIL: VerifyDropReceive FAILED, Rx databuf is not zero: %h",ReadData);
        TbErrorCnt++;
      end

  endtask


  //specification 2 
    
  //VerifyFCSErrReceive verifies that RX data buffer is zero after frame error
  task VerifyFCSErrorReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    //Check all RO bits: Should have only Rx_FrameError set 
    WriteAddress('h02,'h10); //Rx_FCSen should be set in RXSC
    ReadAddress('h02,ReadData); //Rx_SC address is 0x2
    //FCSerr=1; 
    a_VerifyErr_0: assert (ReadData == 'b00000100)
      $display("PASS: VerifyFrameErrorReceive PASSED. Rx_Ready not set");
    else begin
      $display("FAILED: VerifyFrameErrorReceive FAILED. Rx_Ready set");
      TbErrorCnt++;
    end
    
    //a_VerifyErr_2: assert (ReadData[2] == 1)
    //     $display("PASS: VerifyFrameErrorReceive PASSED. Rx_FrameError set");
    //else begin
    //     $display("FAILED: VerifyFrameErrorReceive FAILED. Rx_FrameError not set");
    //     TbErrorCnt++;
    //end
    //
    //a_VerifyErr_3: assert (ReadData[3] == 0)
    //     $display("PASS: VerifyFrameErrorReceive PASSED. Rx_AbortSignal not set");
    //else begin
    //     $display("FAILED: VerifyFrameErrorReceive FAILED. Rx_AbortSignal set");
    //     TbErrorCnt++;
    //end
    //
    //a_VerifyErr_4: assert (ReadData[4] == 0)
    //     $display("PASS: VerifyFrameErrorReceive PASSED. Rx_Buff not set");
    //else begin
    //     $display("FAILED: VerifyFrameErrorReceive FAILED. Rx_Buff set");
    //     TbErrorCnt++;
    //end


    //And Error in FCS checking results in frameerror
    //Check that RX_databuf is zero
    ReadAddress('h03,ReadData);

    a_VerifyFrameErrorReceive_zero: assert (ReadData=='b00000000)
      $display("PASS: VerifyFrameErrorReceive PASSED, Rx_Buff is empty");
    else begin
      $display("FAIL: VerifyFrameErrorReceive FAILED, Rx databuf is not zero: %h",ReadData);
      TbErrorCnt++;
    end
  endtask


  //Rest of specification 16
  //verifyNonByteAlignedReceive should result in frame error 

  task VerifyNonByteAlignedReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;

    ReadAddress('h02, ReadData);
    //Check all RO bits: Should have only Rx_FrameError set
      ReadAddress('h02,ReadData); //Rx_SC address is 0x2
    a_VerifyErr_0: assert (ReadData == 'b00000100)
      $display("PASS: VerifyNonByteAlignedReceive PASSED. Rx_FrameError");
    else begin
      $display("FAILED: VerifyNonByteAlignedReceive FAILED. Rx_FrameError not set");
      TbErrorCnt++;
    end

    //     TbErrorCnt++;
    //end
    //a_VerifyErr_3: assert (ReadData[3] == 0)
    //     $display("PASS: VerifyNonByteAlignedReceive PASSED. Rx_AbortSignal not set");
    //else begin
    //     $display("FAILED: VerifyNonByteAlignedReceive FAILED. Rx_AbortSignal set");
    //     TbErrorCnt++;
    //end
    //a_VerifyErr_4: assert (ReadData[4] == 0)
    //     $display("PASS: VerifyNonByteAlignedReceive PASSED. Rx_Buff not set");
    //else begin
    //     $display("FAILED: VerifyNonByteAlignedReceive FAILED. Rx_Buff set");
    //     TbErrorCnt++;
    //end

  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyNormalReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);
    
	  ReadAddress('h02, ReadData);

    a_VerifyNormalReceive_0: assert(ReadData[0] == 1 )
    	$display("PASS: VerifyNormalReceive PASSED. Rx_Buff has data to read");
    else begin
    	$display("FAILED: VerifyNormalReceive FAILED. Value in Rx_SC is %h", ReadData);
    	TbErrorCnt++;
    end 	
	  
    a_VerifyNormalReceive_2: assert(ReadData[2] == 0 )
      $display("PASS: VerifyNormalReceive PASSED. No Frame error");
    else begin
      $display("FAILED: VerifyNormalReceive FAILED. Value in Rx_SC is %h",ReadData);
      TbErrorCnt++;
    end
	
	  a_VerifyNormalReceive_3: assert(ReadData[3] == 0 )
      $display("PASS: VerifyNormalReceive PASSED. No Abort signal");
    else begin
      $display("FAILED: VerifyNormalReceive FAILED. Value in Rx_SC is %h", ReadData);
      TbErrorCnt++;
    end

 	  a_VerifyNormalReceive_4: assert(ReadData[4] == 0 )
      $display("PASS: VerifyNormalReceive PASSED. No overflow signal");
    else begin
      $display("FAILED: VerifyNormalReceive FAILED. Value in Rx_SC is %h", ReadData);
      TbErrorCnt++;
    end

    //	ReadAddress('h03,ReadData);
  
  	for (int i =0; i< Size; i++) begin
		  ReadAddress('h03,ReadData);
		  a_Rx_Buff_not_full: assert (ReadData == data[i]) 
			$display("PASS: VerifyNormalReceive PASSED. Rx_Buff has correct data");
		else begin
			$display("FAIL: VerifyNormalReceive FAILED. Value in Rx_Buff is %h", ReadData);
	  	TbErrorCnt++;
		end
    end

  endtask


  // VerifyOverflowReceive verifies that rx buff has data, no frame error, 
  // no abort signals and overflow signal is asserted
  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);

    ReadAddress('h02, ReadData);

    a_Verify_Overflow_0: assert ( ReadData[0]==1)
      $display("PASS: VerifyOverflowRecive PASSED. Rx_Buff has data to read");
    else begin
      $display("FAIL: VerifyOverflowReceived FAILED.");
      TbErrorCnt++;
    end 

    a_Verify_Overflow_2: assert (ReadData[2]==0)
      $display("PASS: VerifyOverflowReceive PASSED. No frame error.");
    else begin
      $display("FAIL: VerifyOverflowReceived FAILED.");
      TbErrorCnt++;
    end
    
    a_Verify_Overflow_3: assert (ReadData[3]==0)
      $display("PASS: VerifyOverflowReceive PASSED. No abort signal.");
    else begin
      $display("FAIL: VerifyOverflowReceived FAILED.");
      TbErrorCnt++;
    end

    a_Verify_Overflow_4: assert (ReadData[4]==1)
      $display("PASS: VerifyOverflowReceive PASSED. Overflow signal asserted.");
    else begin
      $display("FAIL: VerifyOverflowReceived FAILED.");
      TbErrorCnt++;
    end

  endtask



  /****************************************************************************
   *                                                                          *
   *                             Simulation code                              *
   *                                                                          *
   ****************************************************************************/

  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    Init(); 

    $display("CHECKING ASSERTION 4");
    TxDataCorrect();
    reset();

    $display("CHECKING ASSERTION 5");
    check_Assertion_5();
    reset(); 

    $display("CHECKING ASSERTION 7");
    check_Assertion_7();
    reset(); 


    $display("CHECKING ASSERTION 8");
    check_Assertion_8();   
    reset();

    $display("CHECKING ASSERTION 9");
    check_Assertion_9();   
    reset();

    // $display("CHECKING ASSERTION 16");
    //check_Assertion_16();   
    //reset();

    $display("CHECKING ASSERTION 18");
    check_Assertion_18();   
    reset();

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive( 10, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 40, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 45, 0, 0, 0, 0, 0, 0); //Normal
    Receive(126, 0, 0, 0, 0, 0, 0); //Normal
    Receive(122, 1, 0, 0, 0, 0, 0); //Abort//VerifyDropReceive should verify correct value in the Rx status/control register
//->that the Rx data buffer is zero after a frame is dropped
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 25, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 47, 0, 0, 0, 0, 0, 0); //Normal
    Receive(100, 0, 0, 0, 0, 1, 0); //Drop
    Receive(100, 0, 1, 0, 0, 0, 0); //FCSerr	
    Receive(100, 0, 0, 1, 0, 0, 0); //NonByteAligned   

    //Transmit: Size, Abort, Overflow
    // Transmit(10, 0, 0); //Normal
    // Transmit()

    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end


  final begin
    $display("*********************************");
    $display("*                               *");
    $display("* \tAssertion Errors: %0d\t  *", TbErrorCnt + uin_hdlc.ErrCntAssertions);
    $display("*                               *");
    $display("*********************************");
  end


  task Init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Address     = 3'b000;
    uin_hdlc.WriteEnable =   1'b0;
    uin_hdlc.ReadEnable  =   1'b0;
    uin_hdlc.DataIn      =     '0;
    //uin_hdlc.Tx          =   1'b1;
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask


  task reset();
		uin_hdlc.Rst = 1'b0;
		#1000ns;
		uin_hdlc.Rst = 1'b1;
		#1000ns;
  endtask

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task InsertFlagOrAbort(int flag);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    if(flag)
      uin_hdlc.Rx = 1'b0;
    else
      uin_hdlc.Rx = 1'b1;
  endtask

  task MakeRxStimulus(logic [127:0][7:0] Data, int Size);
    logic [4:0] PrevData;
    PrevData = '0;
    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          uin_hdlc.Rx = 1'b0;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = Data[i][j];

        PrevData = PrevData >> 1;
        PrevData[4] = Data[i][j];
      end
    end
  endtask


  task Receive(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] ReceiveData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    string msg;
    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";

     
    $display("*************************************************************");
    $display("%t - Starting task Receive %s", $time, msg);
    $display("*************************************************************");

    for (int i = 0; i < Size; i++) begin
      ReceiveData[i] = $urandom;
    end
    ReceiveData[Size]   = '0;
    ReceiveData[Size+1] = '0;

    //Calculate FCS bits;
    GenerateFCSBytes(ReceiveData, Size, FCSBytes);

    ReceiveData[Size]   = FCSBytes[7:0];
    ReceiveData[Size+1] = FCSBytes[15:8];
    
    //Enable FCS
    if(!Overflow && !NonByteAligned)
      WriteAddress('h02, 8'h20);
    else
      WriteAddress('h02, 8'h00); //changed RXSC to its actual address

    //Generate stimulus
    InsertFlagOrAbort(1);
    
    MakeRxStimulus(ReceiveData, Size + 2);
    
    if(Overflow) begin
      OverflowData[0] = 8'h44;
      OverflowData[1] = 8'hBB;
      OverflowData[2] = 8'hCC;
      MakeRxStimulus(OverflowData, 3);
    end 
 
    if(Abort) begin
      InsertFlagOrAbort(0);
    end else begin
      InsertFlagOrAbort(1);
    end

    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    if(Abort)
      VerifyAbortReceive(ReceiveData, Size);
    else if(Overflow)
      VerifyOverflowReceive(ReceiveData, Size);
    else if(Drop)
      VerifyDropReceive(ReceiveData,Size);
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);
    else if(FCSerr)
      VerifyFCSErrorReceive(ReceiveData, Size);
    else if(NonByteAligned)
      VerifyNonByteAlignedReceive(ReceiveData, Size);
    #5000ns;
  endtask



  //4. correct tx data according to tx buffer 
  task TxDataCorrect();
    logic [7:0] Tx_Data;

    for (int i = 0; i < $size(Tx_Data); i++) begin
      Tx_Data[i]= $urandom();
      WriteAddress('h01, Tx_Data[i]); //write value of data to txbuffer
    end

    //Tx_Data=$urandom();
    @(posedge uin_hdlc.Clk);
    WriteAddress('h00,8'b00000010); //TX_SC is h'00, set enabl
    @(posedge uin_hdlc.Clk);

    a_TxDataCorrect: assert (uin_hdlc.Tx_DataOutBuff==Tx_Data)
      $display("PASS: Tx_data=Tx_Buffer");
    else begin
      $error("Fail: Tx_Data is not equal to Tx_Buffer");
      TbErrorCnt++;
    end


    repeat(25) //let task finish
    @(posedge uin_hdlc.Clk);

  endtask
  

task check_Assertion_5(); 
  logic [3:0][7:0]Data;
 // logic Tx_ValidFrame;

  for (int i = 0; i < $size(Data); i++) begin
    Data[i]= $urandom();
    WriteAddress('h01, Data[i]); //write value of data to txbuffer
  end
  WriteAddress('h00,8'b00000010); //RX_SC is h'00, h'10 says that enable is set 
  @(posedge uin_hdlc.Clk);
 repeat(25) //let task finish
	@(posedge uin_hdlc.Clk);

endtask


task check_Assertion_7(); 
  
	  logic [3:0][7:0]Data;
  //logic Tx_ValidFrame;

  for (int i = 0; i < $size(Data); i++) begin
    Data[i]= $urandom();
    WriteAddress('h01, Data[i]); //write value of data to txbuffer
  end
  WriteAddress('h0,8'b00000010); //RX_SC is h'00, set enable
  
 repeat(20)
	@(posedge uin_hdlc.Clk);

endtask 


task check_Assertion_8();

  logic [3:0][7:0]Data;
  //logic Tx_ValidFrame;

  for (int i = 0; i < $size(Data[i]); i++) begin
    Data[i]= $urandom();
    WriteAddress('h01, Data[i]); //write value of data to txbuffer
  end
  WriteAddress('h00,8'b00000110); 
  //	@(posedge uin_hdlc.Clk);
   //WriteAddress('h00,8'b00000010); //RX_SC is h'00, set enable and 
  
 repeat(25) //let task finish
	@(posedge uin_hdlc.Clk);

endtask

task check_Assertion_9();
logic [3:0][7:0]Data;
 for (int i = 0; i < $size(Data[i]); i++) begin
    Data[i]= $urandom();
    WriteAddress('h01, Data[i]); //write value of data to txbuffer
  end
WriteAddress('h00,8'b0000010); //set enable in TX_SC
@(posedge uin_hdlc.Clk);
@(posedge uin_hdlc.Clk);
@(posedge uin_hdlc.Clk);
WriteAddress('h00,8'b0000110); //set AbortFrame in TX_SC

 repeat(25) //let task finish
	@(posedge uin_hdlc.Clk);

endtask

task check_Assertion_18(); 

  logic [3:0][7:0]Data;
  //logic Tx_ValidFrame;

  for (int i = 0; i < 128; i++) begin
    Data[i]= $urandom();
    WriteAddress('h01, Data[i]); //write value of data to txbuffer
  end
  WriteAddress('h00,8'b00000110); //RX_SC is h'00, set enable and 
  //	@(posedge uin_hdlc.Clk);
   //WriteAddress('h00,8'b00000010); //RX_SC is h'00, set enable and 
  
 repeat(25) //let task finish
	@(posedge uin_hdlc.Clk);

endtask

  task GenerateFCSBytes(logic [127:0][7:0] data, int size, output logic[15:0] FCSBytes);
    logic [23:0] CheckReg;
    CheckReg[15:8]  = data[1];
    CheckReg[7:0]   = data[0];
    for(int i = 2; i < size+2; i++) begin
      CheckReg[23:16] = data[i];
      for(int j = 0; j < 8; j++) begin
        if(CheckReg[0]) begin
          CheckReg[0]    = CheckReg[0] ^ 1;
          CheckReg[1]    = CheckReg[1] ^ 1;
          CheckReg[13:2] = CheckReg[13:2];
          CheckReg[14]   = CheckReg[14] ^ 1;
          CheckReg[15]   = CheckReg[15];
          CheckReg[16]   = CheckReg[16] ^1;
        end
        CheckReg = CheckReg >> 1;
      end
    end
    FCSBytes = CheckReg;
  endtask

endprogram
