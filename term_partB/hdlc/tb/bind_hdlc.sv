//////////////////////////////////////////////////
// Title:   bind_hdlc
// Author:  Karianne Krokan Kragseth
// Date:    20.10.2017
//////////////////////////////////////////////////

module bind_hdlc ();

  bind test_hdlc assertions_hdlc u_assertion_bind(
    .ErrCntAssertions   (uin_hdlc.ErrCntAssertions),
    .Clk                (uin_hdlc.Clk),
    .Rst                (uin_hdlc.Rst),
    .Rx                 (uin_hdlc.Rx),
    .Rx_FlagDetect      (uin_hdlc.Rx_FlagDetect),
    .Rx_ValidFrame      (uin_hdlc.Rx_ValidFrame),
    .Rx_AbortDetect     (uin_hdlc.Rx_AbortDetect),
    .Rx_AbortSignal     (uin_hdlc.Rx_AbortSignal),
    .Rx_Overflow        (uin_hdlc.Rx_Overflow),
    .Rx_WrBuff          (uin_hdlc.Rx_WrBuff),
    .Rx_FrameError      (uin_hdlc.Rx_FrameError),
    .Rx_EoF 	        (uin_hdlc.Rx_EoF),
    .Rx_StartZeroDetect (uin_hdlc.Rx_StartZeroDetect),
    .Rx_StartFCS        (uin_hdlc.Rx_StartFCS),
    .Rx_StopFCS         (uin_hdlc.Rx_StopFCS),
    .Rx_Data            (uin_hdlc.Rx_Data),
    .Rx_NewByte         (uin_hdlc.Rx_NewByte),
    .RxD                (uin_hdlc.RxD),
    .Rx_FCSerr          (uin_hdlc.Rx_FCSerr),
    .Rx_Ready           (uin_hdlc.Rx_Ready),
    .Rx_FrameSize       (uin_hdlc.Rx_FrameSize),
    .Rx_DataBuffOut     (uin_hdlc.Rx_DataBuffOut),
    .Rx_FCSen           (uin_hdlc_Rx_FCSen),
    .Rx_RdBuff          (uin_hdlc.Rx_RdBuff),
    .Rx_Drop            (uin_hdlc_Rx_Drop),

    .Tx                 (uin_hdlc.Tx), 
    .Tx_NewByte         (uin_hdlc.Tx_NewByte),
    .Tx_ValidFrame      (uin_hdlc.Tx_ValidFrame),
    .Tx_AbortFrame      (uin_hdlc.Tx_AbortFrame),
    .Tx_WrBuff          (uin_hdlc.Tx_WrBuff),
    .Tx_Data            (uin_hdlc.Tx_Data),
    .Tx_Done           (uin_hdlc.Tx_Done),
    .Tx_FrameSize       (uin_hdlc.Tx_FrameSize),
    .Tx_Enable          (uin_hdlc.Tx_Enable),
    .Tx_DataAvail       (uin_hdlc.Tx_DataAvail),
    .Tx_DataOutBuff     (uin_hdlc.Tx_DataOutBuff),
    .Tx_Full            (uin_hdlc.Tx_Full),
    .Tx_AbortedTrans    (uin_hdlc.Tx_AbortedTrans)
  );

endmodule
