--ALU : do logical and arithmetical operations

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity alu is
  port(
    input1            : in  std_logic_vector(31 downto 0);
    input2            : in  std_logic_vector(31 downto 0);
    aluControlInput   : in  std_logic_vector(3 downto 0); 
    not_zeroControl       : out std_logic;
    aluResult         : out std_logic_vector(31 downto 0)
  );
end alu;

architecture behavioral of alu is
  
  --Operations set:
    --0000 -- addc
    --0001 -- subc
    --0100 -- Negc
	 --0010 -- divc
	 --0011 -- mulc
    --0101 --shift left 
    --0110 --shift right
	 --1000 -- normal add for EA calculations
    --1111  --no op x'zzzzzzzz'
  
  begin
    
    makeOperation : process(input1, input2, aluControlInput)
      
      constant OPERATIONS_LENGTH : integer := 7;
      variable zeroTemp : std_logic_vector(31 downto 0);
      
      begin
      
        not_zeroControl <= '1';
        case aluControlInput is
          when "0000" => aluResult <= (input1(31 downto 16) + input2(31 downto 16)) & (input1(15 downto 0) + input2(15 downto 0)) ; -- addc operation
          
			 when "1000" => aluResult <= std_logic_vector(resize(signed(input1(31 downto 16)), 32)) + input2(31 downto 0) ; -- normal add operation Used for EA calculations

						  
          when "0001" =>
            aluResult <= (input1(31 downto 16) - input2(31 downto 16)) & (input1(15 downto 0) - input2(15 downto 0)); -- subC operation 
            zeroTemp := (input1(31 downto 16) - input2(31 downto 16)) & (input1(15 downto 0) - input2(15 downto 0));
            if (signed(zeroTemp) = x"00000000") then
              not_zeroControl <= '0';
            end if;
          
            
          when "0100" => aluResult <= input1(31 downto 16) & std_logic_vector(unsigned((not (input1(15 downto 0)) + 1))) ; --negc operation
            
									--************************************************************************************				


				when "0010" => aluResult <= STD_LOGIC_VECTOR( to_signed(to_integer(RESIZE ( TO_SIGNED( to_integer(signed(input1(31 downto 16))) * to_integer(signed(input2(31 downto 16))),16),16) + resize(to_signed( to_integer(signed(input1(15 downto 0))) * to_integer(signed(input2(15 downto 0))),16),16))
                         /  to_integer(resize(to_signed( to_integer(signed(input2(31 downto 16))) * to_integer(signed(input2(31 downto 16))),16),16) + resize(to_signed( to_integer(signed(input2(15 downto 0))) * to_integer(signed(input2(15 downto 0))),16),16)  ),16 ))
								 
	                    &  STD_LOGIC_VECTOR( to_signed(to_integer(RESIZE ( TO_SIGNED( to_integer(signed(input1(15 downto 0))) * to_integer(signed(input2(31 downto 16))),16),16) - resize(to_signed( to_integer(signed(input1(31 downto 16))) * to_integer(signed(input2(15 downto 0))),16),16))
                         /  to_integer(resize(to_signed( to_integer(signed(input2(31 downto 16))) * to_integer(signed(input2(31 downto 16))),16),16) + resize(to_signed( to_integer(signed(input2(15 downto 0))) * to_integer(signed(input2(15 downto 0))),16),16)  ),16 )); -- divC operation


								 
					--************************************************************************************				
				
				when "0011" => aluResult <= std_logic_vector(resize(to_signed( to_integer(signed(input1(31 downto 16))) * to_integer(signed(input2(31 downto 16))),16),16)) - std_logic_vector(resize(to_signed( to_integer(signed(input1(15 downto 0))) * to_integer(signed(input2(15 downto 0))),16),16)) 
		                                & std_logic_vector(resize(to_signed( to_integer(signed(input1(31 downto 16))) * to_integer(signed(input2(15 downto 0))),16),16)) + std_logic_vector(resize(to_signed( to_integer(signed(input1(15 downto 0))) * to_integer(signed(input2(31 downto 16))),16),16));  -- mulC operation 
			 
			 
            
          when "0101" => aluResult <= std_logic_vector(shift_left(unsigned(input1),to_integer(unsigned(input2(10 downto 6))))); --sll (shift left logical)
            
          when "0110" => aluResult <= std_logic_vector(shift_right(unsigned(input1),to_integer(unsigned(input2(10 downto 6))))); --srl (shift right logical)
            
          when "1111" => aluResult <= (others => 'Z'); -- no operation (high ampedance)
          
          when others => aluResult <= (others => 'Z');
        end case;
        
    end process makeOperation;
  
end behavioral;
