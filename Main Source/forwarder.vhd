-- an unit to prevent from data hazard with forwarding data from before or after stages

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarder is
  port (
    ex_mem_zdes   : in std_logic_vector(4 downto 0) := "00000";
	 mem_wb_zdes   : in std_logic_vector(4 downto 0) := "00000";
	 id_ex_zs : in std_logic_vector(4 downto 0);
	 id_ex_zt : in std_logic_vector(4 downto 0);
	 ex_mem_RegWrite   : in std_logic := '0';
	 mem_wb_RegWrite   : in std_logic := '0' ; 
	 ForwardA : out std_logic_vector(1 downto 0); --mux selectDataA control signal 
	 ForwardB : out std_logic_vector(1 downto 0)  --mux selectDataB control signal 
  );
end entity;

architecture behavioral of forwarder is
begin
process( ex_mem_zdes ,mem_wb_zdes , id_ex_zs ,id_ex_zt,ex_mem_RegWrite, mem_wb_RegWrite) is --Activate the process when inputs change their status
	begin
				
   if (ex_mem_RegWrite='1'  and(ex_mem_zdes /= "00000") and(ex_mem_zdes  = id_ex_zs)) then 
	ForwardA <=  "10";
	elsif (mem_wb_RegWrite='1'  and(mem_wb_zdes /= "00000") and(ex_mem_zdes  /= id_ex_zs) and (mem_wb_zdes = id_ex_zs) )then 
	ForwardA <=  "01";
    else 
	 ForwardA <="00"; --data come from id/ex 
	 end if;
	 
 
    if (ex_mem_RegWrite='1'  and(ex_mem_zdes /= "00000") and(ex_mem_zdes  = id_ex_zt)) then 
	ForwardB <=  "10";
	elsif (mem_wb_RegWrite='1'  and(mem_wb_zdes /= "00000") and(ex_mem_zdes  /= id_ex_zt) and (mem_wb_zdes = id_ex_zt) )then 
	ForwardB <=  "01";
    else 
	 ForwardB <="00"; --data come from id/ex 
	 end if;
	 
 end process;
 
 
end behavioral;

