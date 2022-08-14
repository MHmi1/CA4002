
--Sign extend : extend logic vector from 16 to 32 bit used for bne instr and effective address computations ..


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity signExtend is
  port(
    input_signal  : in std_logic_vector(15 downto 0); --imm or offset
    output_signal : out std_logic_vector(31 downto 0)
  );
end signExtend;

architecture behavioral of signExtend is
  begin
    output_signal <= std_logic_vector(resize(signed(input_signal), output_signal'length));
end behavioral;
