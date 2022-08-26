LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    COMPONENT alu
    PORT(
         input1, input2 : IN  std_logic_vector(31 downto 0);
         aluControlInput : IN  std_logic_vector(3 downto 0);
         not_zeroControl : OUT  std_logic;
         aluResult : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
   --Inputs
	signal input1, input2: std_logic_vector(31 downto 0) := (others => '0');
   signal aluControlInput : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal not_zeroControl : std_logic;
   signal aluResult : std_logic_vector(31 downto 0);
 
BEGIN
	
   uut: alu PORT MAP ( input1, input2, aluControlInput, not_zeroControl, aluResult );

	--Test Cases
	process begin

		----'addc' test----  (0-20ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (6+9i + 4+15i = 10+24i)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 6, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 9, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 4, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 15, 16) );
		
		aluControlInput <= "0000";
		wait for 10 ns;
		
		--2 (-11+21i + 7+13i = -4+34i)
		input1(31 downto 16) <= std_logic_vector( to_signed ( -11, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 21, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 7, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 13, 16) );
		
		aluControlInput <= "0000";
		wait for 10 ns;
		
		
		
		----'subc' test----  (20-40ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');

		
		--1 (6+9i - 4+15i = 2-6i)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 6, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 9, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 4, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 15, 16) );
		
		aluControlInput <= "0001";
		wait for 10 ns;
		
		--2 (-11+21i - 7+13i = -18+8i)
		input1(31 downto 16) <= std_logic_vector( to_signed ( -11, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 21, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 7, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 13, 16) );
		
		aluControlInput <= "0001";
		wait for 10 ns;
		
		
		
		----'negc' test----  (40-60ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (6+9i => 6-9i)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 6, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 9, 16) );
		
		aluControlInput <= "0100";
		wait for 10 ns;
		
		--2 (-11-4i => -11+4i)
		input1(31 downto 16) <= std_logic_vector( to_signed ( -11, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_signed ( -4, 16) );
		
		aluControlInput <= "0100";
		wait for 10 ns;
		
		
		
		----'divc' test----  (60-80ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (46+9i ÷ 3+4i = 174-157i/25 ===> 6-6i)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 46, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 9, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 3, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 4, 16) );
		
		aluControlInput <= "0010";
		wait for 10 ns;
		
		--2 (-320+17i ÷ 62-7i = -19959-1186i/3893 ===> -5+0i)
		input1(31 downto 16) <= std_logic_vector( to_signed ( -320, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_unsigned ( 17, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 62, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_signed ( -7, 16) );
		
		aluControlInput <= "0010";
		wait for 10 ns;
		
		
		
		----'mulc' test----   (80-100ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (7-11i × 5+4i = 79-27i)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 7, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_signed ( -11, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_unsigned ( 5, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_unsigned ( 4, 16) );
		
		aluControlInput <= "0011";
		wait for 10 ns;
		
		--2 (-1-8i × -6-4i = -26+52i)
		input1(31 downto 16) <= std_logic_vector( to_signed ( -1, 16) );
		input1(15 downto 0)  <= std_logic_vector( to_signed ( -8, 16) );
		
		input2(31 downto 16) <= std_logic_vector( to_signed ( -6, 16) );
		input2(15 downto 0)  <= std_logic_vector( to_signed ( -4, 16) );
		
		aluControlInput <= "0011";
		wait for 10 ns;
		


		----normal add for EA calculations----  (100-120ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (6+Zi + 14 = 20) (a+...i + b = a+b)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 6, 16) );
		
		input2(31 downto 0)  <= std_logic_vector( to_unsigned ( 14, 32) );
		
		aluControlInput <= "1000";
		wait for 10 ns;
		
		--2 (8+Zi + (-16) = -8) (a+...i + b = a+b)
		input1(31 downto 16) <= std_logic_vector( to_unsigned ( 8, 16) );
		
		input2(31 downto 0)  <= std_logic_vector( to_signed ( -16, 32) );
		
		aluControlInput <= "1000";
		wait for 10 ns;
		
		
		
		----no op x'zzzzzzzz'----  (120-140ns)
		
		--reset inputs
		input1 <= (others => 'Z');
		input2 <= (others => 'Z');
		
		--1 (66 , -44 = Z) ==> (... , ... = Z)
		input1(31 downto 0) <= std_logic_vector( to_unsigned ( 66, 32) );
		
		input2(31 downto 0) <= std_logic_vector( to_signed ( -44, 32) );
		
		aluControlInput <= "1111";
		wait for 10 ns;
		
		--2 (-31 , 0 = Z) ==> (... , ... = Z)
		input1(31 downto 0) <= std_logic_vector( to_signed ( -31, 32) );
		
		input2(31 downto 0) <= std_logic_vector( to_unsigned ( 0, 32) );
		
		aluControlInput <= "1111";
		wait for 10 ns;

		wait;
	end process;
END;
