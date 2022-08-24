
--Registers : read/write from/to register data USED in R type instruction ..
--contain 32 bit of 32 registers uesed in fetch and writeback stages


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity registers is
  port(
    writeRegisterFlag : in  std_logic;
    readRegister1     : in  std_logic_vector(4 downto 0);--ZS
    readRegister2     : in  std_logic_vector(4 downto 0); --ZT
    writeRegister     : in  std_logic_vector(4 downto 0); --ZD or ZT
    writeData         : in  std_logic_vector(31 downto 0); --FOR Lc AND R-TYPE INSTR used for writeback stage
    readData1         : out std_logic_vector(31 downto 0); --first operand (zs)
    readData2         : out std_logic_vector(31 downto 0) --seconde operand (zt)
  );
end registers;

architecture behavioral of registers is
  
  type vector_of_mem is array(0 to 31) of std_logic_vector (31 downto 0); --Define the memory of the registers (5 bit for readRegister : 4096 byte register file total size)
  signal registersMem: vector_of_mem := (                                 --Initialize some value randomly in the registers (with positive num..)
        "00000000000000010000000000000010", --0 
        "00000000000000010000000000000001", 
        "00000000000010000000000000000110", 
        "00000000000100000000000000000011", 
        "00000000001000000000000000000000", 
        "00000000000010010000000000000011", --5
        "00000000001000010000000000001010",
        "00000000000100010000000000000000",
        "00000000000010010000000000000010",
        "00000000000000110000000000000101",
        "00000000000001010000000000000000", --10
        "00000000000011000000000000001101",
        "00000000000101000000000000000100",
        "00000000000001100000000000000100",
        "00000000001000010000000000000110",
        "00000000000010010000000000000010", --15
        "00000000000001110000000000000011",
        "00000000000100010000000000000101",
        "00000000001000010000000000001001",
        "00000000000001010000000000001011",
        "00000000000100000000000000000010", --20
        "00000000001000000000000000000100",
        "00000000000000100000000000001000",
        "00000000000001000000000000001001",
        "00000000000010000000000000000001",
        "00000000000010100000000000000011", --25
        "00000000000001100000000000001010",
        "00000000000000110000000000000110",
        "00000000000100010000000000010010",
        "00000000000010010000000000010001",
        "00000000000000010000000000000011", --30
        "00000000001010010000000000000101"
    );
    
    begin
    
      
      readData1 <= registersMem(to_integer(unsigned(readRegister1)));      --Select the register value (using the address saved in readRegister 1 and 2)
      readData2 <= registersMem(to_integer(unsigned(readRegister2)));      --fetching zs and zt from register file

      updateMemory : process(writeRegisterFlag, writeData)
        begin
          checkWrite : if (writeRegisterFlag = '1') then                    
            registersMem(to_integer(unsigned(writeRegister))) <= writeData; --Update registersMem with writeData in writeRegister 
          end if checkWrite;
      end process updateMemory;
      
end behavioral;
