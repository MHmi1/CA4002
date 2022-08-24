library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_Hazard is
 port (
     opcode  : in std_logic_vector(5 downto 0);
	  branch_cond : in std_logic := '0' ;
	  branch_addrin : in std_logic_vector(31 downto 0);
	  addrout : out std_logic_vector(31 downto 0) := "00000000000000000000000000000000" ;
	  if_flush : out std_logic :='0';
	  muxBranchControl : out std_logic :='0'
	 );

end entity;

architecture behavioral of control_Hazard is
begin


process( opcode , branch_cond ,branch_addrin) is
	begin
	
	
	if (branch_cond = '1' and opcode = "000100") then
	 addrout <= branch_addrin;
	 if_flush <='1';
	 muxBranchControl <='1';
	
	 end if;
	 
	
	end process;


END architecture;