LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY registers_tb IS
END registers_tb;
 
ARCHITECTURE behavior OF registers_tb IS 
 
    COMPONENT registers
    PORT(
         writeRegisterFlag : IN  std_logic;
         readRegister1 : IN  std_logic_vector(4 downto 0);
         readRegister2 : IN  std_logic_vector(4 downto 0);
         writeRegister : IN  std_logic_vector(4 downto 0);
         writeData : IN  std_logic_vector(31 downto 0);
         readData1 : OUT  std_logic_vector(31 downto 0);
         readData2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal writeRegisterFlag : std_logic := '0';
   signal readRegister1 : std_logic_vector(4 downto 0) := (others => '0');
   signal readRegister2 : std_logic_vector(4 downto 0) := (others => '0');
   signal writeRegister : std_logic_vector(4 downto 0) := (others => '0');
   signal writeData : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal readData1 : std_logic_vector(31 downto 0);
   signal readData2 : std_logic_vector(31 downto 0);
   
BEGIN
 
   uut: registers PORT MAP (writeRegisterFlag, readRegister1, readRegister2,
									 writeRegister, writeData, readData1, readData2);
	
	--Test Cases
	process begin		
	
		--1 write data in one register
		writeRegisterFlag <= '1';
		writeRegister <= std_logic_vector( to_unsigned( 12, writeRegister'length) );
		writeData <= std_logic_vector( to_unsigned( 137, writeData'length) );
		wait for 10 ns;
		
		--2 write data in one register
		writeRegisterFlag <= '1';
		writeRegister <= std_logic_vector( to_unsigned( 19, writeRegister'length) );
		writeData <= std_logic_vector( to_unsigned( 203, writeData'length) );
		wait for 10 ns;
		
		--3 read the last two registers that have already a value
		writeRegisterFlag <= '0';
		writeRegister <= std_logic_vector( to_unsigned( 12, writeRegister'length) );
		writeData <= std_logic_vector( to_unsigned( 637, writeData'length) );
		readRegister1 <= std_logic_vector( to_unsigned( 12, readRegister1'length) );
		readRegister2 <= std_logic_vector( to_unsigned( 19, readRegister2'length) );
		wait for 10 ns;
		
      wait;
   end process;

END;
