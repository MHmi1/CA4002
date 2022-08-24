library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Hazard_detection_unit is
 port (
 
	 if_id_zs : in std_logic_vector(4 downto 0);
	 if_id_zt : in std_logic_vector(4 downto 0);
	 
	 id_ex_zt : in std_logic_vector(4 downto 0);
	 id_ex_memRead   : in std_logic := '0';
	 
	 pc_write   : out std_logic := '0' ;
	 if_id_write   : out std_logic:= '0';
	 mux_controler   : out std_logic:= '0';
	 stall_en   : out std_logic := '0'
	 
	 );

end entity;

architecture behavioral of Hazard_detection_unit is
begin


process( if_id_zs,if_id_zt,id_ex_zt,id_ex_memRead) is
	begin
	
	
	if (id_ex_memRead = '1' and (ID_EX_zt = IF_ID_zs or ID_EX_zt = IF_ID_zt)) then
	 
	 pc_write   <= '1' ;
	 if_id_write   <= '1';
	 mux_controler   <= '1';
	 stall_en   <= '1';
	 
	 else 
	 
	 pc_write   <= '0' ;
	 if_id_write   <= '0';
	 mux_controler   <= '0';
	 stall_en   <= '0';
	 
	 end if;
	 
	
	end process;


END architecture;