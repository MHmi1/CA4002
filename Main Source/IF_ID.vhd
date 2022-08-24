-- if_id intermediate register ( otherwise pipeline1)
-- IF_ID : first pipeline in the cpu. Store PC+4 and getInstruction for one clock cycle


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IF_ID is
  port (
    clk               : in std_logic;
    resetPL1          : in std_logic;
    storedPC          : in std_logic_vector(31 downto 0);
    storedInstruction : in std_logic_vector(31 downto 0);
	 Hazard_flag       : in std_logic := '0';
	 if_flush       : in std_logic := '0';
	

    --OUTPUT
    getPC             : out std_logic_vector(31 downto 0);
    getInstruction    : out std_logic_vector(31 downto 0)
  );
end IF_ID;

architecture behavioral of IF_ID is
  
  signal sInstruction, sPC : std_logic_vector(31 downto 0);
  
  begin
    
    loadAddress : process(clk, resetPL1 , if_flush)       --Activate the process when the clock change his status 
      begin
        checkClock : 
          if resetPL1 = '1' or if_flush ='1' then 
            sInstruction  <= "00000000000000000000000000000000";
            sPC           <= "00000000000000000000000000000000";
          elsif clk = '1' and clk'event  and Hazard_flag ='0'  then   -- update Intermediate register with new values
            sInstruction  <= storedInstruction;
            sPC           <= storedPC;
          end if;
    end process loadAddress;
    
    getInstruction  <= sInstruction; --hold current data and signals
    getPC           <= sPC;
    
end behavioral;
