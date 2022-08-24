-- exe_mem intermediate register ( otherwise pipeline3)
--Pipeline3 get all control signals and data from prevoius stage and hold them for one clock cycle.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity exe_mem is
  port (
    clk             : in std_logic;
    resetPL        : in std_logic;
    --Store control unit signal
    --WB:
    storedMemToReg  : in std_logic;
    storedRegWrite  : in std_logic;
    --M:
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
    storedWriteReg  : in std_logic_vector(4 downto 0); --address of zt or zd
    --OUTPUT
    getMemToReg   : out std_logic;
    getRegWrite   : out std_logic;
    getBranch     : out std_logic;        
    getMemRead    : out std_logic;
    getMemWrite   : out std_logic;
    getBranchAddr : out std_logic_vector(31 downto 0);
    getZero       : out std_logic;
    getAluResult  : out std_logic_vector(31 downto 0);
    getReadData2  : out std_logic_vector(31 downto 0);
    getWriteReg   : out std_logic_vector(4 downto 0)
  );
end exe_mem;

architecture behavioral of exe_mem is
  
  signal sMemToReg, sRegWrite, sBranch, sMemRead, sMemWrite, sZero : std_logic;
  signal  sBranchAddr, sAluresult, sReadData2 : std_logic_vector(31 downto 0);
  signal sWriteReg : std_logic_vector(4 downto 0);
  
  begin
    
    loadAddress : process(clk, resetPL)       --Activate the process when the clock change his status 
      begin
        checkClock : 
          if resetPL = '1' then 
            sMemToReg   <= '0';
            sRegWrite   <= '0';
            sBranch     <= '0';        
            sMemRead    <= '0';
            sMemWrite   <= '0';
            sBranchAddr <= "00000000000000000000000000000000";
            sZero       <= '0'; 
            sAluResult  <= "00000000000000000000000000000000";
            sReadData2  <= "00000000000000000000000000000000";
            sWriteReg   <= "00000";
          elsif clk = '1' and clk'event then  -- update Intermediate register with new values
            sMemToReg   <= storedMemToReg;
            sRegWrite   <= storedRegWrite;
            sBranch     <= storedBranch;        
            sMemRead    <= storedMemRead;
            sMemWrite   <= storedMemWrite;
            sBranchAddr <= storedBranchAddr;
            sZero       <= storedZero;
            sAluResult  <= storedAluResult;
            sReadData2  <= storedReadData2;
            sWriteReg   <= storedWriteReg;
          end if;
    end process loadAddress;
    
    getMemToReg   <= sMemToReg;  --hold current data and signals
    getRegWrite   <= sRegWrite;
    getBranch     <= sBranch;        
    getMemRead    <= sMemRead;
    getMemWrite   <= sMemWrite;
    getBranchAddr <= sBranchAddr;
    getZero       <= sZero;
    getAluResult  <= sAluResult;
    getReadData2  <= sReadData2;
    getWriteReg   <= sWriteReg;
    
end behavioral;
