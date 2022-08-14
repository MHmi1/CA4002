-- an unit to decrease penalty from  control hazard with EARLY BANCH PREDICTION
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity n_bit_comparator is
  generic(
    n : natural := 32
  );  
  port (
    in1   : in std_logic_vector(n-1 downto 0);
	 in2   : in std_logic_vector(n-1 downto 0);

	 eq_res   : out std_logic :='0'
  );
end entity;

architecture behavioral of n_bit_comparator is
begin
process( in1,in2) is --Activate the process when inputs change their status
	begin
				
   if ( (in1(31 downto 16) - in2(31 downto 16) = "0000000000000000" )) and  ((in1(15 downto 0) - in2(15 downto 0) = "0000000000000000" )) then 
	eq_res <=  '1';

    else 
	 eq_res <=  '0'; 
	 end if;
	    
	 
 end process;
 
 
end behavioral;

