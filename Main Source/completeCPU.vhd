--Final design of complex number processor
--all components and functional units connect to each other (make datapath) 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity completeCPU is
  port(
    clock  : in std_logic;
    rstPC  : in std_logic;
    rstPL  : in std_logic
    );
end completeCPU;

architecture behavioral of completeCPU is

  component instructionFetch is
    port(
      clk                 : in std_logic;
      resetProgCounter    : in std_logic;
      resetPipeline1      : in std_logic;
      muxBranchControlIn1 : in std_logic;
      muxBranchExtIn1     : in std_logic_vector(31 downto 0);
			 pcwrite_hazard : in std_logic;
	 if_id_write_hazard : in std_logic;
	  if_flushin1 : in std_logic;
      pcOut1              : out std_logic_vector(31 downto 0);
      instructionOut1     : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component instructionDecode is
    port(
      --pipeline signal
      clk                 : in std_logic;
      resetPipeline2      : in std_logic;
      --Registers external input
      regWriteFlagIn2     : in std_logic;
      regWriteIn2         : in std_logic_vector(4 downto 0);
      dataWriteIn2        : in std_logic_vector(31 downto 0);
      --Instruction to compute
      instructionIn2      : in std_logic_vector(31 downto 0);
      --Program counter + 4
      programCounterIn2   : in std_logic_vector(31 downto 0);
      --Cotrol unit signal
      memToRegOut2        : out std_logic;
      regWriteOut2        : out std_logic;
      branchOut2          : out std_logic;        
      memReadOut2         : inout std_logic;
      memWriteOut2        : out std_logic;
      regDstOut2          : out std_logic;
      aluSrcOut2          : out std_logic;
      aluOpOut2           : out std_logic_vector(3 downto 0);
      --Various datas get from instruction
      programCounterOut2  : out std_logic_vector(31 downto 0);
      readData1Out2       : out std_logic_vector(31 downto 0);
      readData2Out2       : out std_logic_vector(31 downto 0);
      extendedSignalOut2  : out std_logic_vector(31 downto 0);
		registerZSOut2      : out std_logic_vector(4 downto 0);
      registerZTOut2      : inout std_logic_vector(4 downto 0);
      registerZDOut2      : out std_logic_vector(4 downto 0);
		 mul_or_divout2      : out std_logic_vector(1 downto 0);
	 pcwrite_hazard_OUT2 :  out std_logic;
	 if_id_write_hazard_OUT2  :  out std_logic;
	  branchAddrOut2 : out std_logic_vector(31 downto 0);
	   if_flushout2  :  out std_logic;
		muxBranchControlOUT2 :  out std_logic
	 
    );
  end component;
  
  component execution is
    port(
    clk               : in std_logic;
    resetPipeline3    : in std_logic;
    --Control signal
    memToRegIn3       : in std_logic;
    regWriteIn3       : in std_logic;
    branchIn3         : in std_logic;        
    memReadIn3        : in std_logic;
    memWriteIn3       : in std_logic;
    regDstIn3         : in std_logic;
    aluSrcIn3         : in std_logic;
    aluOpIn3          : in std_logic_vector(3 downto 0);
    --Various datas get from instruction
    programCounterIn3 : in std_logic_vector(31 downto 0);
    readData1In3      : in std_logic_vector(31 downto 0);
    readData2In3      : in std_logic_vector(31 downto 0);
    extendedSignalIn3 : in std_logic_vector(31 downto 0);
	 registerZSIn3     : in std_logic_vector(4 downto 0);
    registerZTIn3     : in std_logic_vector(4 downto 0);
    registerZDIn3     : in std_logic_vector(4 downto 0);
	 
	 --Various datas for forwarder unit 
	 ex_mem_zdes_for   : in std_logic_vector(4 downto 0);
	 mem_wb_zdes_for   : in std_logic_vector(4 downto 0);
	 ex_mem_RegWrite_for   : in std_logic;
	 mem_wb_RegWrite_for   : in std_logic;
	 mux_3to1_in1 : in std_logic_vector(31 downto 0);
	 mux_3to1_in2 : in std_logic_vector(31 downto 0);
	 
    --OUTPUT
    memToRegOut3      : out std_logic;
    regWriteOut3      : out std_logic;
    branchOut3        : out std_logic;        
    memReadOut3       : out std_logic;
    memWriteOut3      : out std_logic;
    branchAddrOut3    : out std_logic_vector(31 downto 0);
    zeroFlagOut3      : out std_logic;
    aluResultOut3     : out std_logic_vector(31 downto 0);
    readData2Out3     : out std_logic_vector(31 downto 0);
    registerOut3      : out std_logic_vector(4 downto 0)
  );
  end component;
  
  component memoryOperations is
  port(
    clk              : in std_logic;
    resetPipeline4   : in std_logic;
    memToRegIn4      : in std_logic;
    regWriteIn4      : in std_logic;
    branchIn4        : in std_logic;        
    memReadIn4       : in std_logic;
    memWriteIn4      : in std_logic;
    branchAddrIn4    : in std_logic_vector(31 downto 0);
    zeroFlagIn4      : in std_logic;
    aluResultIn4     : in std_logic_vector(31 downto 0);
    readData2In4     : in std_logic_vector(31 downto 0);
    registerIn4      : in std_logic_vector(4 downto 0);
	 registerIn4_temp     : inout std_logic_vector(4 downto 0); --we need feedback from this port (forwarder unit)
    --OUTPUT
    memToRegOut4     : out std_logic;
    regWriteOut4     : out std_logic;
    branchOut4       : out std_logic;
    branchAddrOut4   : out std_logic_vector(31 downto 0);
    aluResultOut4    : out std_logic_vector(31 downto 0);
    readDataMemOut4  : out std_logic_vector(31 downto 0);
    registerOut4     : out std_logic_vector(4 downto 0)
  );
  end component;
  
  component mux is
    generic(
      dimension : natural := 32
    );  
    port(
      controlSignal  : in std_logic;
      signal1        : in std_logic_vector(dimension - 1 downto 0);
      signal2        : in std_logic_vector(dimension - 1 downto 0);
      selectedSignal : out std_logic_vector(dimension - 1 downto 0)
    );
  end component;
  
  
  --Block 1 in / Block 4 out
  signal sBranchToFetch: std_logic;
  signal sBranchAdrrToFetch : std_logic_vector(31 downto 0);
  --Block 2 In / Block 1 out
  signal sPcToPartition, sInstructionToPartition : std_logic_vector(31 downto 0);
  --Block 2 in / Block 4 out
  signal sRegWriteFlagToFetch : std_logic;
  signal sWriteRegToFetch : std_logic_vector(4 downto 0);
  --Block 2 in / Mux out
  signal sDataWriteToFetch : std_logic_vector(31 downto 0);
  --Block 3 in / Block 2 out
  
  --Block 3 in / Block 4 out
    signal sRegWriteFlagToforw : std_logic;
  signal sWriteRegToforw : std_logic_vector(4 downto 0);
  
    --Control signal
  signal sMemToRegToElab, sRegWriteToElab, sBranchToElab   : std_logic;
  signal sMemReadToElab, sMemWriteToElab, sRegDstToElab, sAluSrcToElab  : std_logic;
  signal sAluOpToElab : std_logic_vector(3 downto 0);
    --Various Data
  signal  sProgramCounterToElab, sReadData1ToElab : std_logic_vector(31 downto 0);
  signal sReadData2ToElab, sExtdSignToElab : std_logic_vector(31 downto 0);
  signal sRegZSToElab,sRegZtToElab, sRegZdToElab : std_logic_vector(4 downto 0);
  --Block 4 in / Block 3 out
    --Control
  signal sMemToRegToMemOp, sRegWriteToMemOp  : std_logic; 
  signal sBranchToMemOp, sMemReadToMemOp, sMemWriteToMemOp, sZeroFlagToMemOp : std_logic;
    --Various Data
  signal  sBranchAdrrToMemOp : std_logic_vector(31 downto 0);
  signal sReadData2ToMemOp, sAluResultToMemOp : std_logic_vector(31 downto 0);
  signal sWriteRegToMemOp : std_logic_vector(4 downto 0);
  --Mux in / Block 4 out
  signal sMemToRegToMux : std_logic;
  signal sReadDataMemToMux, sAluResultToMux : std_logic_vector(31 downto 0);
  	signal ex_mem_zdes_feedbackSIG : std_logic_vector(4 downto 0); --to use in forwarder unit 
	signal s_mul_or_div : std_logic_vector(1 downto 0); --to use for divide and mult unit control 
  
   signal Spcwrite_hazard      :  std_logic := '0' ;
	 signal Sif_id_write_hazard  :   std_logic := '0' ;
	 signal Sif_flush  : std_logic := '0' ;
	
	 
  begin 
  
        a_fetching : instructionFetch
      port map (clk => clock, resetProgCounter => rstPC, resetPipeline1 => rstPL, muxBranchControlIn1 => sBranchToFetch, muxBranchExtIn1 => sBranchAdrrToFetch,
         pcOut1 => sPcToPartition, instructionOut1 => sInstructionToPartition , pcwrite_hazard => Spcwrite_hazard,  if_id_write_hazard => Sif_id_write_hazard ,if_flushin1 =>sif_flush);
	
	 
    b_instrDecode : instructionDecode
      port map (clk => clock, resetPipeline2 => rstPL, regWriteFlagIn2 => sRegWriteFlagToFetch, regWriteIn2 => sWriteRegToFetch, dataWriteIn2 => sDataWriteToFetch,
        instructionIn2 => sInstructionToPartition, programCounterIn2 => sPcToPartition, memToRegOut2 => sMemToRegToElab, regWriteOut2 => sRegWriteToElab,
         branchOut2 => sBranchToElab, memReadOut2 => sMemReadToElab, memWriteOut2 => sMemWriteToElab, regDstOut2 => sRegDstToElab,
        aluSrcOut2 => sAluSrcToElab, aluOpOut2 => sAluOpToElab, programCounterOut2 => sProgramCounterToElab, 
        readData1Out2 => sReadData1ToElab, readData2Out2 => sReadData2ToElab, extendedSignalOut2 => sExtdSignToElab,registerZSOut2 => sRegZSToElab, registerZTOut2 => sRegZtToElab,
        registerZDOut2 => sRegZdToElab, mul_or_divout2 => s_mul_or_div , pcwrite_hazard_out2 => Spcwrite_hazard, if_id_write_hazard_out2 => Sif_id_write_hazard , if_flushout2 =>sif_flush,branchAddrOut2=>sBranchAdrrToFetch , muxBranchControlOUT2=> sBranchToFetch);
        
		  
    c_execution : execution
      port map (clk => clock, resetPipeline3 => rstPL, memToRegIn3 => sMemToRegToElab, regWriteIn3 => sRegWriteToElab,
         branchIn3 => sBranchToElab, memReadIn3 => sMemReadToElab, memWriteIn3 => sMemWriteToElab, regDstIn3 => sRegDstToElab,
        aluSrcIn3 => sAluSrcToElab, aluOpIn3 => sAluOpToElab, programCounterIn3 => sProgramCounterToElab, 
        readData1In3 => sReadData1ToElab, readData2In3 => sReadData2ToElab, extendedSignalIn3 => sExtdSignToElab,registerZSIn3 => sRegZSToElab, registerZTIn3 => sRegZtToElab,
        registerZDIn3 => sRegZdToElab, memToRegOut3 => sMemToRegToMemOp, regWriteOut3 => sRegWriteToMemOp, branchOut3 => sBranchToMemOp,
        memReadOut3 => sMemReadToMemOp, memWriteOut3 => sMemWriteToMemOp, branchAddrOut3 => sBranchAdrrToMemOp,
        zeroFlagOut3  => sZeroFlagToMemOp, aluResultOut3 => sAluResultToMemOp, readData2Out3 => sReadData2ToMemOp, registerOut3 => sWriteRegToMemOp,ex_mem_zdes_for=> ex_mem_zdes_feedbackSIG , mem_wb_zdes_for => sWriteRegToFetch , mem_wb_RegWrite_for=>sRegWriteFlagToFetch,ex_mem_RegWrite_for=>sRegWriteToMemOp,mux_3to1_in1=>sDataWriteToFetch,mux_3to1_in2 =>sAluResultToMemOp);
        
		  
    d_memOp : memoryOperations
      port map (clk => clock, resetPipeline4 => rstPL, memToRegIn4 => sMemToRegToMemOp, regWriteIn4 => sRegWriteToMemOp,
      branchIn4 => sBranchToMemOp, memReadIn4 => sMemReadToMemOp, memWriteIn4 => sMemWriteToMemOp, 
      branchAddrIn4 => sBranchAdrrToMemOp, zeroFlagIn4  => sZeroFlagToMemOp, aluResultIn4 => sAluResultToMemOp, readData2In4 => sReadData2ToMemOp, 
      registerIn4 => sWriteRegToMemOp, memToRegOut4 => sMemToRegToMux, regWriteOut4 => sRegWriteFlagToFetch, 
      branchOut4 => open, branchAddrOut4 => open, aluResultOut4 => sAluResultToMux, 
      readDataMemOut4 => sReadDataMemToMux, registerOut4 => sWriteRegToFetch,registerIn4_temp => ex_mem_zdes_feedbackSIG );
      
		
    e_memToRegSelector : mux 
      generic map (32)
      port map (controlSignal => sMemToRegToMux, signal1 => sAluResultToMux, signal2 => sReadDataMemToMux, selectedSignal => sDataWriteToFetch);
   
end behavioral;



	   
	 
    

