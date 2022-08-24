
--Program counter : store instruction and get the new instruction to do


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity programCounter is
  port (
    clk            : in std_logic;
    resetPC        : in std_logic;
	 Hazard_flag       : in std_logic := '0';
    nextAddress    : in std_logic_vector(31 downto 0);
    currentAddress : out std_logic_vector(31 downto 0)
  );
end programCounter;

architecture behavioral of programCounter is
  
  signal address : std_logic_vector(31 downto 0);
  begin
    
    loadAddress : process(clk, resetPC , Hazard_flag )       --Activate the process when the clock change his status 
      begin
        checkClock : 
          if resetPC = '1' then 
            address <= "00000000000000000000000000000000";
                   elsif clk = '1' and clk'event  and Hazard_flag = '0' then --if rising edge of clock enable then update pc with new address
       
            address <= nextAddress;
          end if;
    end process loadAddress;
    
    currentAddress <= address; --hold current address 
    
end behavioral;
