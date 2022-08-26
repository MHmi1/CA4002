LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY dataMemory_tb IS
END dataMemory_tb;
 
ARCHITECTURE behavior OF dataMemory_tb IS 
    COMPONENT dataMemory
    PORT(
         memWriteFlag : IN  std_logic;
         memReadFlag : IN  std_logic;
         writeData : IN  std_logic_vector(31 downto 0);
         address : IN  std_logic_vector(31 downto 0);
         readData : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal memWriteFlag : std_logic := '0';
   signal memReadFlag : std_logic := '0';
	signal writeData : std_logic_vector(31 downto 0) := (others => '0');
   signal address : std_logic_vector(31 downto 0) := (others => '0');
   
 	--Outputs
   signal readData : std_logic_vector(31 downto 0);

 
BEGIN
 
   uut: dataMemory PORT MAP(memWriteFlag, memReadFlag, writeData, address, readData);
	
	 --Test Cases
    process begin
	 
		--1
		
		--write data (7 in address 12)
		memWriteFlag <= '1';
		memReadFlag  <= '0';
		writeData <= std_logic_vector(to_unsigned (7, writeData'length));
		address <= std_logic_vector(to_unsigned (12, address'length));
		wait for 10 ns;
		
		--read data (from address 12)
		memWriteFlag <= '0';
		memReadFlag  <= '1';
		address <= std_logic_vector(to_unsigned (12, address'length));
		wait for 10 ns;
		
		--2
		
		--write data (-3 in address 20)
		memWriteFlag <= '1';
		memReadFlag  <= '0';
		writeData <= std_logic_vector(to_signed (-3, writeData'length));
		address   <= std_logic_vector(to_unsigned (20, address'length));
		wait for 10 ns;
		
		--read data (from address 20)
		memWriteFlag <= '0';
		memReadFlag  <= '1';
		address <= std_logic_vector(to_unsigned (20, address'length));
		wait for 10 ns;
		
		--3
		
		--read data (from address 36)
		memWriteFlag <= '0';
		memReadFlag  <= '1';
		address <= std_logic_vector(to_unsigned (36, address'length));
		wait for 10 ns;
		
      wait;
   end process;

END;
