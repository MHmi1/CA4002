
--Components : include register file, sign Extender , control unit and pipeline2(ID_EX) and etc ..
--decode unit  (slicing instruction to needed data )

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instructionDecode is
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
    --pc + 4
    programCounterIn2   : in std_logic_vector(31 downto 0);
    --Cotrol unit signals
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
	 mul_or_divout2      : out std_logic_vector(1 downto 0); --control signal to determine mulc or divc operation in the exe stage
   pcwrite_hazard_OUT2 :  out std_logic;
	 if_id_write_hazard_OUT2  :  out std_logic;
	 branchAddrOut2 : out std_logic_vector(31 downto 0);
	 if_flushout2  :  out std_logic;
	 muxBranchControlOUT2 :  out std_logic
  );
end instructionDecode;

architecture behavioral of instructionDecode is
  
  component control is --parallel with register file unit
    port(
      opcode        : in std_logic_vector(5 downto 0);
      functField    : in std_logic_vector(5 downto 0);
      regDst        : out std_logic;
      branch        : out std_logic;
      memRead       : out std_logic;
      memWrite      : out std_logic;
      memToReg      : out std_logic;
      aluSrc        : out std_logic;
      regWrite      : out std_logic;
      aluOperation  : out std_logic_vector (3 downto 0);
		mul_or_div    : out std_logic_vector (1 downto 0)
    );
  end component;
  
  component registers is  --parallel with control unit
    port(
      writeRegisterFlag : in  std_logic;
      readRegister1     : in  std_logic_vector(4 downto 0);
      readRegister2     : in  std_logic_vector(4 downto 0);
      writeRegister     : in  std_logic_vector(4 downto 0);
      writeData         : in  std_logic_vector(31 downto 0);
      readData1         : out std_logic_vector(31 downto 0);
      readData2         : out std_logic_vector(31 downto 0)
    );
  end component;
  
component control_Hazard is

 port (
     opcode  : in std_logic_vector(5 downto 0);
	  branch_cond : in std_logic;
	  
	  branch_addrin : in std_logic_vector(31 downto 0);
	    
	  addrout : out std_logic_vector(31 downto 0);
	  if_flush : out std_logic :='0';
	  muxBranchControl : out std_logic :='0'
	 );
end component;


  component signExtend is --parallel with register file unit
    port(
      input_signal  : in std_logic_vector(15 downto 0);
      output_signal : out std_logic_vector(31 downto 0)
    );
  end component;
  
  
    component Hazard_detection_unit is
 port ( 
	 if_id_zs : in std_logic_vector(4 downto 0);
	 if_id_zt : in std_logic_vector(4 downto 0);
	 
	 id_ex_zt : in std_logic_vector(4 downto 0);
	 id_ex_memRead   : in std_logic;
	 
	 pc_write   : out std_logic := '0' ;
	 if_id_write   : out std_logic:= '0';
	 mux_controler   : out std_logic:= '0';
	 stall_en   : out std_logic := '0'
	 
	 );
end component;


  component ID_EX is  -- intermediate register With the largest size to store data and signals
    port (
      clk             : in std_logic;
      resetPL         : in std_logic;
      --Store control unit signal
      --USED for WB:
      storedMemToReg  : in std_logic;
      storedRegWrite  : in std_logic;
      --USED for MEM:
      storedBranch    : in std_logic;        
      storedMemRead   : in std_logic;
      storedMemWrite  : in std_logic;
      --USED for EXE:
      storedRegDst    : in std_logic;
      storedAluSrc    : in std_logic;
      storedAluOp     : in std_logic_vector(3 downto 0);
      
      storedPC        : in std_logic_vector(31 downto 0);   --Store PC +4 and Jump
      --Store data from component "register file"
      storedReadData1 : in std_logic_vector(31 downto 0);
      storedReadData2 : in std_logic_vector(31 downto 0);
      
      storedSignExt   : in std_logic_vector(31 downto 0); --Save the instruction extended 
    
      --Stored write registers from "getInstruction"  but control unit select the just one
      storedWriteRegZT  : in std_logic_vector(4 downto 0);
      storedWriteRegZD  : in std_logic_vector(4 downto 0);
		storedmul_or_div : in std_logic_vector(1 downto 0);
      --Outputs and USAGE of each
      getMemToReg   : out std_logic; --Lc instr 
      getRegWrite   : out std_logic; --Lc and R-type instr 
      getBranch     : out std_logic; --BNE instr        
      getMemRead    : out std_logic; --Lc instr
      getMemWrite   : out std_logic; --sc instr
      getRegDst     : out std_logic; --common between instr
      getAluSrc     : out std_logic;
      getAluOp      : out std_logic_vector(3 downto 0);
      getPC         : out std_logic_vector(31 downto 0);
      getReadData1  : out std_logic_vector(31 downto 0); --ZS
      getReadData2  : out std_logic_vector(31 downto 0); --ZT
      getSignExt    : out std_logic_vector(31 downto 0); -- used for BNE and Lc and Sc instr
		getWriteRegZS : out std_logic_vector(4 downto 0);
      getWriteRegZT : out std_logic_vector(4 downto 0);
      getWriteRegZD : out std_logic_vector(4 downto 0);
		getmul_or_div : out std_logic_vector(1 downto 0) -- control signal to determine mulc or divc operation in the exe stage
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
  
  
  component n_bit_comparator is
  generic(
    n : natural := 32
  );  
  port (
    in1   : in std_logic_vector(n-1 downto 0);
	 in2   : in std_logic_vector(n-1 downto 0);

	 eq_res   : out std_logic :='0'
  );
end component;

  component adder is --parallel with alu unit
    generic(
      dimension : natural := 32
    );  
    port(
      addend1  : in std_logic_vector(dimension - 1 downto 0);
      addend2  : in std_logic_vector(dimension - 1 downto 0);
      sum      : out std_logic_vector(dimension - 1 downto 0)
    );
  end component;

  component shifterLeft is --parallel with alu unit
    generic(
      inputDim     : natural := 32;
      outputDim    : natural := 32;
      bitToShift   : natural := 2 
    );  
    port(
      inputV   : in std_logic_vector(inputDim - 1 downto 0);
      outputV  : out std_logic_vector(outputDim - 1 downto 0)
    );
  end component;
  
  
  signal sExtendResult : std_logic_vector(31 downto 0);
  signal sReadData1, sReadData2 : std_logic_vector(31 downto 0);
  signal sShiftedInstr : std_logic_vector(27 downto 0);
  --Cotrol output signal
  signal sRegDst, sBranch, sMemRead, sMemWrite, sMemToReg, sAluSrc, sRegWrite : std_logic := '0';
  signal smul_or_div : std_logic_vector(1 downto 0) := "00";
  signal sAluOp : std_logic_vector(3 downto 0);
  signal prova : std_logic := '1';
  signal Shazard_mux : std_logic:='0';
  signal Shazard_mux_res : std_logic_vector(12 downto 0);
  signal scomparator_res : std_logic;
  signal sExtendedShiftedSignal : std_logic_vector(31 downto 0);
  signal sBranchAddrRes : std_logic_vector(31 downto 0);
	  
  
  begin
    
	     shiftSignal : shifterLeft -- to generate Extended Shifted offset 
      generic map (32, 32, 2)
      port map (inputV => sExtendResult, outputV => sExtendedShiftedSignal);
		
		 branchAdd : adder -- pc+4 + {Extended Shifted offset}
      generic map (32)
      port map (addend1 => programCounterIn2, addend2 => sExtendedShiftedSignal, sum => sBranchAddrRes);
		
		
	 com: n_bit_comparator
	 port map(in1 => sReadData1,in2 =>sReadData2,eq_res => scomparator_res);
	 
    extendSignal : signExtend
      port map (input_signal => instructionIn2(15 downto 0), output_signal => sExtendResult); --SIGN EXTEND OFFSET
    
	 control_Hazard_unit : control_Hazard
	 port map ( opcode => instructionIn2(31 downto 26), branch_cond => scomparator_res,branch_addrin => sBranchAddrRes,addrout => branchAddrOut2,if_flush => if_flushout2 ,muxBranchControl =>muxBranchControlOUT2);
	 
    readRegister : registers
      port map (writeRegisterFlag => regWriteFlagIn2, readRegister1 => instructionIn2(25 downto 21), readRegister2 => instructionIn2(20 downto 16), 
      writeRegister => regWriteIn2, writeData => dataWriteIn2, readData1 => sReadData1, readData2 => sReadData2);
  
    setControlFlagS : control
      port map (opcode => instructionIn2(31 downto 26), functField => instructionIn2(5 downto 0), regDst => sRegDst, branch => sBranch, 
        memRead => sMemRead, memWrite => sMemWrite, memToReg => sMemToReg, aluSrc => sAluSrc, regWrite => sRegWrite, aluOperation => sAluOp , mul_or_div =>smul_or_div);
    
    
    pipeline : ID_EX
      port map (clk => clk, resetPL => resetPipeline2, storedMemToReg => Shazard_mux_res(8), storedRegWrite => Shazard_mux_res(6), storedBranch => Shazard_mux_res(11),
        storedMemRead => Shazard_mux_res(10), storedMemWrite => Shazard_mux_res(9), storedRegDst => Shazard_mux_res(12)  , storedAluSrc => Shazard_mux_res(7), storedAluOp => Shazard_mux_res(5 downto 2), 
         storedPC => programCounterIn2, storedReadData1 => sReadData1, storedReadData2 => sReadData2, storedSignExt => sExtendResult, 
        storedWriteRegZT => instructionIn2(20 downto 16) , storedWriteRegZD => instructionIn2(15 downto 11), getMemToReg => memToRegOut2, 
        getRegWrite =>regWriteOut2, getBranch => branchOut2, getMemRead => memReadOut2, getMemWrite => memWriteOut2, getRegDst => regDstOut2, getAluSrc => aluSrcOut2, getAluOp => aluOpOut2,getPC => programCounterOut2, getReadData1 => readData1Out2, 
        getReadData2 => readData2Out2, getSignExt => extendedSignalOut2, getWriteRegZS => registerZSOut2 , getWriteRegZT => registerZTOut2, getWriteRegZD => registerZDOut2,storedmul_or_div => Shazard_mux_res(1 downto 0), getmul_or_div => mul_or_divout2);
        
		  
		  hazard_detection : Hazard_detection_unit
		  port map( if_id_zs=>instructionIn2(25 downto 21),if_id_zt => instructionIn2(20 downto 16) ,id_ex_zt => registerZTOut2 , id_ex_memRead => memReadOut2 ,mux_controler => shazard_mux , pc_write =>pcwrite_hazard_OUT2 , if_id_write => if_id_write_hazard_OUT2 ,stall_en => open);
				  
		  
		   control_sel : mux 
      generic map (13)
      port map ( controlsignal => shazard_mux , signal1 => (sRegDst& sBranch& sMemRead& sMemWrite& sMemToReg& sAluSrc& sRegWrite &sAluOp &smul_or_div) , signal2 => "0000000000000", selectedSignal => Shazard_mux_res);	
        
end behavioral;
