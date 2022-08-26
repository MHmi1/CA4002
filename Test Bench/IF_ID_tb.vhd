--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY IF_ID_tb IS
END IF_ID_tb;
 
ARCHITECTURE behavior OF IF_ID_tb IS 
 
    COMPONENT IF_ID
    PORT(
         clk : IN  std_logic;
         resetPL1 : IN  std_logic;
         storedPC : IN  std_logic_vector(31 downto 0);
         storedInstruction : IN  std_logic_vector(31 downto 0);
         Hazard_flag : IN  std_logic;
         if_flush : IN  std_logic;
         getPC : OUT  std_logic_vector(31 downto 0);
         getInstruction : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal resetPL1 : std_logic := '0';
   signal storedPC : std_logic_vector(31 downto 0) := (others => '0');
   signal storedInstruction : std_logic_vector(31 downto 0) := (others => '0');
   signal Hazard_flag : std_logic := '0';
   signal if_flush : std_logic := '0';

 	--Outputs
   signal getPC : std_logic_vector(31 downto 0);
   signal getInstruction : std_logic_vector(31 downto 0);
	
   -- Clock period definition
   constant clk_period : time := 20 ns;
	
BEGIN
 
   uut: IF_ID PORT MAP (clk, resetPL1, storedPC, storedInstruction, Hazard_flag,
	                     if_flush, getPC, getInstruction);

	-- Clock process 
	clk_process :process begin
		 clk <= '0';
		 wait for clk_period/2;
		 clk <= '1';
		 wait for clk_period/2;
	end process;

	--Test Cases
	process begin		
		--the exact moment when clock changes from '0' to '1' --> "getPC <= storedPC , getInstruction <= storedInstruction" 
		
		storedPC <= std_logic_vector(to_unsigned(48, storedPC'length));
		storedInstruction <= "00000000001010000010100000110010";
		wait for 15 ns;

		storedPC <= std_logic_vector(to_unsigned(4, storedPC'length));
		storedInstruction <= "00010000001000111111111111111101";
		wait for 10 ns;

	wait;
	end process;

END;
