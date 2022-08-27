
--Mux_2TO1 : select the output signal between 2 input signal


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity mux is
  generic(
    dimension : natural := 32
  );  
  port(
    controlSignal  : in std_logic;
    signal1        : in std_logic_vector(dimension - 1 downto 0);
    signal2        : in std_logic_vector(dimension - 1 downto 0);
    selectedSignal : out std_logic_vector(dimension - 1 downto 0)
  );
end mux;

architecture behavioral of mux is
  begin
  
   process(signal1,signal2,controlSignal) is
begin
if(controlSignal = '0') then
	selectedSignal <= signal1;
elsif(controlSignal = '1') then
	selectedSignal <= signal2;

end if;

end process;
    
end behavioral;
