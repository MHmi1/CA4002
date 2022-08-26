LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY instructionMemory_tb IS
END instructionMemory_tb;
 
ARCHITECTURE behavior OF instructionMemory_tb IS 

    COMPONENT instructionMemory
    PORT(
         instrMemIn : IN  std_logic_vector(31 downto 0);
         instruction : OUT  std_logic_vector(31 downto 0)
         );
    END COMPONENT;
   
   --Inputs
   signal instrMemIn : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal instruction : std_logic_vector(31 downto 0);

BEGIN
 
   uut: instructionMemory PORT MAP(instrMemIn, instruction);
	
	--Test Cases
	process begin	
	
		--1 ((20÷4)+1 = 6) ==> 6 of instruction (or memory(5)) in memory is "00000000010000010001100000110011" 
		instrMemIn <= std_logic_vector(to_unsigned (20, instrMemIn'length));
		wait for 10 ns;	
		
		--2 ((0÷4)+1 = 1) ==> 1 of instruction (or memory(0)) in memory is "00000000010000110000100000110000"
      instrMemIn <= std_logic_vector(to_unsigned (0, instrMemIn'length));
		wait for 10 ns;
			
		--3 ((44÷4)+1 = 12) ==> memory only has 10 instructions now and memory(11) has a default value '0' or NOP
      instrMemIn <= std_logic_vector(to_unsigned (44, instrMemIn'length));
		wait for 10 ns;
		
      wait;
   end process;

END;
