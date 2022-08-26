LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.all;

ENTITY adder_tb IS
	generic( dimension : natural := 32 );
END adder_tb;
 
ARCHITECTURE behavior OF adder_tb IS 
  
    COMPONENT adder
		 PORT(
				addend1, addend2 : IN  std_logic_vector(dimension-1 downto 0);
				sum : OUT  std_logic_vector(dimension-1 downto 0) 
			   );
    END COMPONENT;
    
   --Inputs
   signal addend1, addend2 : std_logic_vector(dimension-1 downto 0) := (others => '0');

 	--Outputs
   signal sum : std_logic_vector(dimension-1 downto 0);
 
BEGIN
 
   uut: adder PORT MAP (addend1,addend2,sum);
	 
	 --Test Cases
	 process begin
	 
	   --1 (11+7 = 18)
		addend1 <= std_logic_vector( to_unsigned( 11, addend1'length) );
		addend2 <= std_logic_vector( to_unsigned( 7 , addend2'length) );
		wait for 10 ns;
		
		--2 (-8+5 = -3)
		addend1 <= std_logic_vector( to_signed( -8, addend1'length) );
		addend2 <= std_logic_vector( to_unsigned( 5 , addend2'length) );
		
		--addend1 <= (3 => '1', others => '0');
		--addend2 <= (0 => '1', others => '0');
		wait;
		
	end process;
END;
