LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY programCounter_tb IS
END programCounter_tb;
 
ARCHITECTURE behavior OF programCounter_tb IS 
 
    COMPONENT programCounter
    PORT(
         clk : IN  std_logic;
         resetPC : IN  std_logic;
         Hazard_flag : IN  std_logic := '0';
         nextAddress : IN  std_logic_vector(31 downto 0);
         currentAddress : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal resetPC : std_logic := '0';
   signal Hazard_flag : std_logic := '0';
   signal nextAddress : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal currentAddress : std_logic_vector(31 downto 0);
 
   constant clk_period : time := 20 ns;
 
BEGIN
 
	uut: programCounter PORT MAP(clk,resetPC,Hazard_flag,nextAddress,currentAddress);
	 
   -- Clock process 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	--Test Cases
	process begin		
		--the exact moment when clock changes from '0' to '1' --> "currentAddress <= nextaddress" 
		
		nextAddress <= std_logic_vector(to_unsigned (4, nextAddress'length));
		wait for 25 ns;
		
		nextAddress <= std_logic_vector(to_unsigned (12, nextAddress'length));
		wait for 10 ns;
		
		nextAddress <= std_logic_vector(to_unsigned (132, nextAddress'length));
		wait for 10 ns;
		
      wait;
   end process;

END;
