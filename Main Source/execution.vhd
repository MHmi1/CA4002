-- main part of CPU for COMPUTATION operations
--Components : ALU, pipeline3(exe_mem), adder, and mux , forwarder unit , etc ..

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execution is
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
	 ex_mem_zdes_for   : in std_logic_vector(4 downto 0);
	 mem_wb_zdes_for   : in std_logic_vector(4 downto 0);
	 ex_mem_RegWrite_for   : in std_logic;
	 mem_wb_RegWrite_for   : in std_logic;
	 mux_3to1_in1 : in std_logic_vector(31 downto 0);
	 mux_3to1_in2 : in std_logic_vector(31 downto 0);
    --OUTPUTs
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
end execution;

architecture behavioral of execution is
  
  component alu is
    port(
      input1            : in  std_logic_vector(31 downto 0);
      input2            : in  std_logic_vector(31 downto 0);
      aluControlInput   : in  std_logic_vector(3 downto 0); 
      not_zeroControl       : out std_logic;
      aluResult         : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component exe_mem is
    port (
      clk             : in std_logic;
      resetPL         : in std_logic;
      --Store control unit signal
      --USED for wb:
      storedMemToReg  : in std_logic;
      storedRegWrite  : in std_logic;
      --USED for mem:
      storedBranch    : in std_logic;        
      storedMemRead   : in std_logic;
      storedMemWrite  : in std_logic;
      --BranchAddr
      storedBranchAddr: in std_logic_vector(31 downto 0);
      --ALU 
      storedZero      : in std_logic;
      storedAluResult : in std_logic_vector(31 downto 0);
      --Store data from registers
      storedReadData2 : in std_logic_vector(31 downto 0);
      --Stored write registers
      storedWriteReg  : in std_logic_vector(4 downto 0);
		
		
      --OUTPUT
      getMemToReg   : out std_logic;
      getRegWrite   : out std_logic;
      --getJump       : out std_logic;
      getBranch     : out std_logic;        
      getMemRead    : out std_logic;
      getMemWrite   : out std_logic;
      getBranchAddr : out std_logic_vector(31 downto 0);
      getZero       : out std_logic;
      getAluResult  : out std_logic_vector(31 downto 0);
      getReadData2  : out std_logic_vector(31 downto 0);
      getWriteReg   : out std_logic_vector(4 downto 0)
    );
  end component;
 
  
  component mux is --parallel with alu unit
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
  
  
component MUX_4TO1 is
    generic(n: natural := 32);
    port(
        signal0 : in std_logic_vector(n-1 downto 0);
        signal1 : in std_logic_vector(n-1 downto 0);
        signal2 : in std_logic_vector(n-1 downto 0);
        signal3 : in std_logic_vector(n-1 downto 0);

        controlSignal: in std_logic_vector(1 downto 0);
         selectedSignal: out std_logic_vector(n-1 downto 0)
    );
end component;

component forwarder is --parallel with alu unit
  port (
    ex_mem_zdes   : in std_logic_vector(4 downto 0);
	 mem_wb_zdes   : in std_logic_vector(4 downto 0);
	 id_ex_zs : in std_logic_vector(4 downto 0);
	 id_ex_zt : in std_logic_vector(4 downto 0);
	 ex_mem_RegWrite   : in std_logic;
	 mem_wb_RegWrite   : in std_logic; 
	 ForwardA : out std_logic_vector(1 downto 0);
	 ForwardB : out std_logic_vector(1 downto 0) 
  );
end component;

  
  signal sZero : std_logic;
  signal sSelectedWriteReg : std_logic_vector(4 downto 0);
  signal sAluData2 , sAluResult : std_logic_vector(31 downto 0);
  signal sExtendedShiftedSignal, sBranchAddrRes : std_logic_vector(31 downto 0);
  
 
  
  --needed signals to use for data forwardeing 
  	SIGNAL s_ex_mem_zdes_for   :  std_logic_vector(4 downto 0);
	SIGNAL s_mem_wb_zdes_for   :  std_logic_vector(4 downto 0);
	SIGNAL s_ex_mem_RegWrite_for   :  std_logic;
	SIGNAL s_mem_wb_RegWrite_for   :  std_logic;
   SIGNAL SForwardA : std_logic_vector(1 downto 0);
	SIGNAL SForwardB : std_logic_vector(1 downto 0);
	SIGNAL s_mux_3to1_in1: std_logic_vector(31 downto 0);
	SIGNAL s_mux_3to1_in2: std_logic_vector(31 downto 0);
	SIGNAL s_mux_3to1_A_RES: std_logic_vector(31 downto 0);
	SIGNAL s_mux_3to1_B_RES: std_logic_vector(31 downto 0);
   SIGNAL s_mux_B_SEL: std_logic_vector(1 downto 0) ;
  
  begin
  
   s_ex_mem_zdes_for   <= ex_mem_zdes_for;
	s_mem_wb_zdes_for   <=  mem_wb_zdes_for;
	s_ex_mem_RegWrite_for   <= ex_mem_RegWrite_for;
	s_mem_wb_RegWrite_for  <= mem_wb_RegWrite_for;
	s_mux_3to1_in1 <=mux_3to1_in1;
	s_mux_3to1_in2 <= mux_3to1_in2;

   --s_mux_B_SEL<= SForwardB;
	
	
    selectRegister : mux -- to select destination register from zt or zd
      generic map (5)
      port map (controlSignal => regDstIn3, signal1 => registerZTIn3, signal2 => registerZDIn3, selectedSignal => sSelectedWriteReg );
      
    --selectSecondData : mux -- to select from rt of signex{offset}
     -- generic map (32)
      --port map (controlSignal => aluSrcIn3, signal1 => readData2In3, signal2 => extendedSignalIn3, selectedSignal => sAluData2);

    --shiftSignal : shifterLeft -- to generate Extended Shifted offset 
      --generic map (32, 32, 2)
     -- port map (inputV => extendedSignalIn3, outputV => sExtendedShiftedSignal);
      
		mux_B_controler : mux 
		generic map (2)
		port map (controlSignal=> aluSrcIn3 ,  signal1 => SForwardB, signal2 => "11" , selectedSignal => s_mux_B_SEL);
		
      selectDataA :MUX_4TO1
      generic map (32)
      port map (controlSignal =>SForwardA, signal0 => readData1In3, signal1 => s_mux_3to1_in1,signal2 =>s_mux_3to1_in2,signal3 =>"00000000000000000000000000000000", selectedSignal => s_mux_3to1_A_RES);
		
		  selectDataB : MUX_4TO1 
      generic map (32)
      port map (controlSignal => s_mux_B_SEL, signal0 =>readData2In3, signal1 => s_mux_3to1_in2,signal2 => s_mux_3to1_in1, signal3 => extendedSignalIn3, selectedSignal => s_mux_3to1_B_RES);


    aluElaboration : alu
      port map (input1 => s_mux_3to1_A_RES, input2 => s_mux_3to1_B_RES, aluControlInput => aluOpIn3, not_zeroControl => sZero, aluResult => sAluResult);
      
   -- branchAdd : adder -- pc+4 + {Extended Shifted offset}
     -- generic map (32)
     -- port map (addend1 => programCounterIn3, addend2 => sExtendedShiftedSignal, sum => sBranchAddrRes);
      
    pipeline : exe_mem
      port map (clk => clk, resetPL => resetPipeline3, storedMemToReg => memToRegIn3, storedRegWrite => regWriteIn3,
        storedBranch => branchIn3, storedMemRead => memReadIn3, storedMemWrite => memWriteIn3, storedBranchAddr => sBranchAddrRes, storedZero => sZero, storedAluResult => sAluResult, storedReadData2 => s_mux_3to1_B_RES, storedWriteReg => sSelectedWriteReg, getMemToReg => memToRegOut3, 
        getRegWrite => regWriteOut3, getBranch => branchOut3, getMemRead => memReadOut3, getMemWrite => memWriteOut3, 
         getBranchAddr => branchAddrOut3, getZero => zeroFlagOut3, getAluResult => aluResultOut3, getReadData2 => readData2Out3, 
        getWriteReg => registerOut3);
		  
		  
		  forwarder_comp : forwarder 
		  port map (s_ex_mem_zdes_for,s_mem_wb_zdes_for,registerZSIn3,registerZTIn3,s_ex_mem_RegWrite_for,s_mem_wb_RegWrite_for,SForwardA,SForwardB);
       
	 
end behavioral;
