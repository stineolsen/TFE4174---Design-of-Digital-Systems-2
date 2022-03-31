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

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);

    ReadAddress('h02, ReadData);

    a_Vertify_Overflow_0: assert ( ReadData[0]==1)
	$display("PASS: VertifyOverflowRecive PASSED. Rx_Buff has data to read");
    else begin
	$display("FAIL: VertifyOverflowReceived FAILED.");
	TbErrorCnt++;
    end 
    a_Verify_Overflow_2: assert (ReadData[2]==0)
	$display("PASS: VerifyOverflowReceive PASSED. No frame error.");
    else begin
	$display("FAIL: VertifyOverflowReceived FAILED.");
        TbErrorCnt++;
    end
	
	 a_Verify_Overflow_3: assert (ReadData[3]==0)
        $display("PASS: VerifyOverflowReceive PASSED. No abort signal.");
    else begin
        $display("FAIL: VertifyOverflowReceived FAILED.");
        TbErrorCnt++;
    end

	 a_Verify_Overflow_4: assert (ReadData[4]==1)
        $display("PASS: VerifyOverflowReceive PASSED. Overflow signal asserted.");
    else begin
        $display("FAIL: VertifyOverflowReceived FAILED.");
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

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive( 10, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 40, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 45, 0, 0, 0, 0, 0, 0); //Normal
    Receive(126, 0, 0, 0, 0, 0, 0); //Normal
    Receive(122, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 25, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 47, 0, 0, 0, 0, 0, 0); //Normal

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
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
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
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);

    #5000ns;
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
