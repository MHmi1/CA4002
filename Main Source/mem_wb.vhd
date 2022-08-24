-- mem_wb intermediate register ( otherwise pipeline4)
--store data and control signal for one clock cycle 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_wb is
  port (
    clk               : in std_logic;
    resetPL           : in std_logic;
    --Store control unit signal
    --USED for WB:
    storedMemToReg    : in std_logic;
    storedRegWrite    : in std_logic;
    --Store data read from memory
    storedReadDataMem : in std_logic_vector(31 downto 0);
    --ALU
    storedAluResult   : in std_logic_vector(31 downto 0);
    --Stored write registers
    storedWriteReg    : in std_logic_vector(4 downto 0);
    --OUTPUTs
    getMemToReg       : out std_logic;
    getRegWrite       : out std_logic;
    getReadDataMem    : out std_logic_vector(31 downto 0);
    getAluResult      : out std_logic_vector(31 downto 0);
    getWriteReg       : out std_logic_vector(4 downto 0)
    
  );
end mem_wb;

architecture behavioral of mem_wb is
  
  signal sMemToReg, sRegWrite : std_logic;
  signal sAluresult, sReadDataMem : std_logic_vector(31 downto 0);
  signal sWriteReg : std_logic_vector(4 downto 0);
  
  begin
    
    loadAddress : process(clk, resetPL)       --Activate the process when the clock change his status 
      begin
        checkClock : 
          if resetPL = '1' then    --set all control signals and data  to zero 
            sMemToReg     <= '0';
            sRegWrite     <= '0';
            sReadDataMem  <= "00000000000000000000000000000000";
            sAluResult    <= "00000000000000000000000000000000";
            sWriteReg     <= "00000";
          elsif clk = '1' and clk'event then  -- update Intermediate register with new values
            sMemToReg     <= storedMemToReg;
            sRegWrite     <= storedRegWrite;
            sReadDataMem  <= storedReadDataMem;
            sAluResult    <= storedAluResult;
            sWriteReg     <= storedWriteReg;
          end if;
    end process loadAddress;
    
    getMemToReg     <= sMemToReg;  --hold current data and signals
    getRegWrite     <= sRegWrite;
    getReadDataMem  <= sReadDataMem;
    getAluResult    <= sAluResult;
    getWriteReg     <= sWriteReg;
    
end behavioral;
