--test bench file of complex number cpu and generate clocking 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_CPU is

end tb_CPU;


architecture tb_behavioral of tb_CPU is

  component completeCPU is
    port(
      clock     : in std_logic;
      rstPC     : in std_logic;
      rstPL     : in std_logic
    );
  end component;
  
  signal clk, resetPC, resetPL : std_logic;

  begin
  
  UUT : completeCPU
    port map (clock => clk, rstPC => resetPC, rstPL => resetPL);
    
  clock_p : process
      variable clk_tmp : std_logic :='0';
      begin
        clk_tmp := not clk_tmp;
        clk <= clk_tmp;
        wait for 60 ns;
    end process;
  
  reset : process
    begin
      resetPC <= '1';
      resetPL <= '1';
      wait for 3 ns;
      
      resetPC <= '0';
      resetPL <= '0';
      wait;
  end process;
  
end tb_behavioral;

  
