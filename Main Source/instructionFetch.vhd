
--component : PC, instruction memory and adder  and etc ... 
--fetch unit 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instructionFetch is
  port(
    --PC signal
    clk                 : in std_logic;
    resetProgCounter    : in std_logic;
    --Pipeline signal
    resetPipeline1      : in std_logic;
    --Branch mux signal
    muxBranchControlIn1 : in std_logic;
    muxBranchExtIn1     : in std_logic_vector(31 downto 0);
	 	 pcwrite_hazard : in std_logic;
	 if_id_write_hazard : in std_logic;
	 if_flushin1 : in std_logic;
   
    --Outputs
    pcOut1              : out std_logic_vector(31 downto 0);
    instructionOut1     : out std_logic_vector(31 downto 0)
  );
end instructionFetch;

architecture behavioral of instructionFetch is

  component programCounter is
    port (
      clk            : in std_logic;
      resetPC        : in std_logic;
		Hazard_flag       : in std_logic;
      nextAddress    : in std_logic_vector(31 downto 0);
      currentAddress : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component instructionMemory is
    port (
      instrMemIn    :  in std_logic_vector (31 downto 0); --Program Counter input
      instruction   :  out std_logic_vector (31 downto 0) --create an output that pass the instruction read from instructions.dat
    );
  end component;
  
  component adder is
    generic(
      dimension : natural := 32
    );  
    port(
      addend1   : in std_logic_vector(dimension - 1 downto 0);
      addend2   : in std_logic_vector(dimension - 1 downto 0);
      sum       : out std_logic_vector(dimension - 1 downto 0)
    );
  end component;
  
  component IF_ID is
    port (
      clk               : in std_logic;
      resetPL1          : in std_logic;
		Hazard_flag       : in std_logic := '0';
      storedPC          : in std_logic_vector(31 downto 0);
      storedInstruction : in std_logic_vector(31 downto 0);
		if_flush       : in std_logic := '0';
      getPC             : out std_logic_vector(31 downto 0);
      getInstruction    : out std_logic_vector(31 downto 0)
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
  
  signal sPcIn        : std_logic_vector(31 downto 0);
  signal sOutPC       : std_logic_vector(31 downto 0);
  signal sPlusFour    : std_logic_vector(31 downto 0);
  signal sAddResult   : std_logic_vector(31 downto 0);
  signal sStoreInstr  : std_logic_vector(31 downto 0);
  signal sMuxBOut     : std_logic_vector(31 downto 0);
  
  begin
    
    sPlusFour <= "00000000000000000000000000000100";
    
    --Select PC + 4 or branch address
    branchMux : mux
      generic map (32)
      port map (controlSignal => muxBranchControlIn1, signal1 => sAddResult, signal2 => muxBranchExtIn1, selectedSignal => sPcIn);
    
    nextAddress : programCounter
      port map (clk => clk, resetPC => resetProgCounter , nextAddress => sPcIn, currentAddress => sOutPC ,  Hazard_flag  => pcwrite_hazard);
    --Add + 4 to program counter and calc next possible address
    sum : adder
      generic map (32)
      port map (addend1 => sOutPC, addend2 => sPlusFour, sum => sAddResult);
    --Get address from PC and get instruction to compute
    get_memory : instructionMemory
      port map (instrMemIn => sOutPC, instruction => sStoreInstr);
    --Store readed instruction into pipeline
    pipeline : IF_ID
      port map (clk => clk, resetPL1 => resetPipeline1, storedPC => sAddResult, storedInstruction => sStoreInstr, getPC => pcOut1, getinstruction => instructionOut1 , if_flush => if_flushin1 , Hazard_flag =>if_id_write_hazard );
end behavioral;
