LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY mux_tb IS
END mux_tb;
 
ARCHITECTURE behavior OF mux_tb IS 
 
    COMPONENT mux
    PORT(
         controlSignal : IN  std_logic;
         signal1 : IN  std_logic_vector(31 downto 0);
         signal2 : IN  std_logic_vector(31 downto 0);
         selectedSignal : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal controlSignal : std_logic := '0';
   signal signal1 : std_logic_vector(31 downto 0) := (others => '0');
   signal signal2 : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal selectedSignal : std_logic_vector(31 downto 0);

BEGIN
   uut: mux PORT MAP (controlSignal, signal1, signal2, selectedSignal);
	
	--Test Cases
	process begin		
		
		--1 (26 and 9) => first one --> 26
		controlSignal <= '0';
		signal1 <= std_logic_vector( to_unsigned( 26, signal1'length) );
		signal2 <= std_logic_vector( to_unsigned( 9, signal2'length) );
		wait for 10 ns;
		
		--2 (15 and 33) => second one --> 33
		controlSignal <= '1';
		signal1 <= std_logic_vector( to_unsigned( 15, signal1'length) );
		signal2 <= std_logic_vector( to_unsigned( 33, signal2'length) );
		wait for 10 ns;
		
      wait;
   end process;

END;
