-- id_ex Intermediate register ( otherwise pipeline2) With the largest size between registers
--Pipeline2 get all control signals and data from prevoius stage and hold them for one clock cycle.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX is
  port (
    clk             : in std_logic;
    resetPL         : in std_logic;
    --Store control unit signal
    --USED for WB:
    storedMemToReg  : in std_logic;
    storedRegWrite  : in std_logic;
    --USED for mem:
    storedBranch    : in std_logic;        
    storedMemRead   : in std_logic;
    storedMemWrite  : in std_logic;
    --USED for EXE:
    storedRegDst    : in std_logic;
    storedAluSrc    : in std_logic;
    storedAluOp     : in std_logic_vector(3 downto 0);
    --Store PC +4 and Jump
    storedPC        : in std_logic_vector(31 downto 0);
    --Store data from component "registers"
    storedReadData1 : in std_logic_vector(31 downto 0); --zs
    storedReadData2 : in std_logic_vector(31 downto 0); --zt
    --Save the instruction extended
    storedSignExt   : in std_logic_vector(31 downto 0);

    storedWriteRegZS : in std_logic_vector(4 downto 0);
	 storedWriteRegZT : in std_logic_vector(4 downto 0);
    storedWriteRegZD : in std_logic_vector(4 downto 0);
	 storedmul_or_div : in  std_logic_vector(1 downto 0);
    --OUTPUTs
    getMemToReg   : out std_logic;
    getRegWrite   : out std_logic;
    getBranch     : out std_logic;        
    getMemRead    : out std_logic;
    getMemWrite   : out std_logic;
    getRegDst     : out std_logic;
    getAluSrc     : out std_logic;
    getAluOp      : out std_logic_vector(3 downto 0);
    getPC         : out std_logic_vector(31 downto 0);
    getReadData1  : out std_logic_vector(31 downto 0);
    getReadData2  : out std_logic_vector(31 downto 0);
    getSignExt    : out std_logic_vector(31 downto 0);
	 getWriteRegZS : out std_logic_vector(4 downto 0);
    getWriteRegZT : out std_logic_vector(4 downto 0);
    getWriteRegZD : out std_logic_vector(4 downto 0) ;
    getmul_or_div : out  std_logic_vector(1 downto 0)
  );
end ID_EX;

architecture behavioral of ID_EX is
  
  signal sMemToReg, sRegWrite, sBranch, sMemRead, sMemWrite, sRegDst, sAluSrc : std_logic;
  signal sAluOP : std_logic_vector(3 downto 0);
  signal sPC, sReadData1, sReadData2, sSignExt : std_logic_vector(31 downto 0);
  signal sWriteRegZS,sWriteRegZT, sWriteRegZD : std_logic_vector(4 downto 0);
  signal smul_or_div  : std_logic_vector(1 downto 0);
  begin
    
    loadAddress : process(clk, resetPL)       --Activate the process when the clock change his status 
      begin
        checkClock : 
          if resetPL = '1' then 
            sMemToReg  <= '0';
            sRegWrite  <= '0';
            sBranch    <= '0';        
            sMemRead   <= '0';
            sMemWrite  <= '0';
            sRegDst    <= '0';
            sAluSrc    <= '0';
            sAluOp     <= "0000";
            sPC        <= "00000000000000000000000000000000";
            sReadData1 <= "00000000000000000000000000000000";
            sReadData2 <= "00000000000000000000000000000000";
            sSignExt   <= "00000000000000000000000000000000";
				sWriteRegZS <= "00000";
            sWriteRegZT <= "00000";
            sWriteRegZD <= "00000";
				smul_or_div <= "00";
          elsif clk = '1' and clk'event then  -- update Intermediate register with new values
            sMemToReg   <= storedMemToReg;
            sRegWrite   <= storedRegWrite;
            sBranch     <= storedBranch;        
            sMemRead    <= storedMemRead;
            sMemWrite   <= storedMemWrite;
            sRegDst     <= storedRegDst;
            sAluSrc     <= storedAluSrc;
            sAluOp      <= storedAluOp;
            sPC         <= storedPC;
            sReadData1  <= storedReadData1;
            sReadData2  <= storedReadData2;
            sSignExt    <= storedSignExt;
				sWriteRegZS <= storedWriteRegZS;
            sWriteRegZT <= storedWriteRegZT;
            sWriteRegZD <= storedWriteRegZD;
				smul_or_div <= storedmul_or_div;
				
          end if;
    end process loadAddress;
    
    getMemToReg   <= sMemToReg;       --hold current data and signals
    getRegWrite   <= sRegWrite; 
    getBranch     <= sBranch;        
    getMemRead    <= sMemRead;
    getMemWrite   <= sMemWrite;
    getRegDst     <= sRegDst;
    getAluSrc     <= sAluSrc;
    getAluOp      <= sAluOp;
    getPC         <= sPC;
    getReadData1  <= sReadData1;
    getReadData2  <= sReadData2;
    getSignExt    <= sSignExt;
	 getWriteRegZS <= sWriteRegZS;
    getWriteRegZT <= sWriteRegZT;
    getWriteRegZD <= sWriteRegZD;
	 getmul_or_div <= smul_or_div;
    
end behavioral;
