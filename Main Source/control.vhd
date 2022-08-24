
--Control unit : read opcode and func then generate the muxs/components flag 


--OPCODE    FUNCT     FUNCT(bitS)  OPRTN     regDst    memToReg    regW    memR    memW    branch   aluSrc    

--Arithmetic
--000000    addc      110000       0000        1         0          1        0       0        0       0           
--000000    subc      110001       0001        1         0          1        0       0        0       0        

--Data transfer
--010000    lc        XXXXXX       1000        0         1          1        1       0        0       1         
--010001    sc        XXXXXX       1000        X         X          0        0       1        0       1        

--Logical
--000000    Negc      110100       0100        1         0          1        0       0        0       0         
--000000    divc      110011       0010        1         0          1        0       0        0       0         
--000000    mulc      110010       0011        1         0          1        0       0        0       0         
--000000    shL       110101       0101        1         0          1        0       0        0       0         
--000000    shR       110110       0110        1         0          1        0       0        0       0         

--cond. branch
--000100    bne       XXXXXX       0001        X         X          0        0       0        1       0?x        


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity control is -- 12 bit input and 13 bit output with 9 control signal
  port(
    opcode        : in std_logic_vector(5 downto 0);
    functField    : in std_logic_vector(5 downto 0);
    regDst        : out std_logic;
    branch        : out std_logic;
    memRead       : out std_logic;
    memWrite      : out std_logic;
    memToReg      : out std_logic;
    aluSrc        : out std_logic;
    regWrite      : out std_logic;
    aluOperation  : out std_logic_vector (3 downto 0);
	 mul_or_div    : out std_logic_vector (1 downto 0)
  );
end control;


architecture behavioral of control is
  
  begin
    --Set controls flag based on opcode
    muxControlLines : process(opcode, functField)
      begin
        category : case opcode is
          --R-types
          when "000000" =>
            regDst    <= '1';
            branch    <= '0';
            memRead   <= '0';
            memWrite  <= '0';
            memToReg  <= '0';
            regWrite  <= '1';
				mul_or_div    <="00";
            --Check function field and set the alu operation to do
            if (unsigned(functField) = "110000") then      --Addc
              aluSrc  <= '0';
              aluOperation  <= "0000";
            elsif (unsigned(functField) = "110001") then  --Subc
              aluSrc  <= '0';
              aluOperation  <= "0001";
           elsif (unsigned(functField) = "110010") then  --Mulc
              aluSrc  <= '0';
              aluOperation  <= "0011";
				  mul_or_div    <="01"; --mult operation if div_mult unit is available
           elsif (unsigned(functField) = "110011") then  --  Divc
              aluSrc  <= '0';
              aluOperation  <= "0010";
				  mul_or_div    <="10"; --division operation if div_mult unit is available
            elsif (unsigned(functField) = "110100") then  --Negc
              aluSrc  <= '0';
              aluOperation  <= "0100";
            elsif (unsigned(functField) = "110101") then  --shift left
              aluSrc  <= '0';
              aluOperation  <= "0101";
            elsif (unsigned(functField) = "110110") then  --shift right
              aluSrc  <= '0';
              aluOperation  <= "0110";
            elsif (unsigned(functField) = "000000") then  --pipeline reset case
              regWrite  <= '0';
              aluSrc  <= '0';                           --Avoid bad write on register
              aluOperation  <= "1111";
            else
              regWrite  <= '0';
              aluSrc  <= '0';
              aluOperation  <= "1111";
            end if;
            
				
				
			-- i_types	
          --Data transfer "01XXXX" 
          when "010000" =>     --Lc
            regDst        <= '0';
            branch        <= '0';
            memRead       <= '1';
            memWrite      <= '0';
            memToReg      <= '1';
            aluSrc        <= '1';
            regWrite      <= '1';
            aluOperation  <= "1000"; --normal add for ea computing
				mul_or_div    <="00";
                
          when "010001" =>     --Sc
            regDst        <= '0';  --X?
            branch        <= '0';
            memRead       <= '0';
            memWrite      <= '1';
            memToReg      <= '1';  --X?
            aluSrc        <= '1';
            regWrite      <= '0';
            aluOperation  <= "1000"; --normal add for ea computing
				mul_or_div    <="00";
            
        
          
          --Conditional branch "0001XX"
          when "000100" =>      --BNE
            regDst    <= '0';   --X?
            branch    <= '1';
            memRead   <= '0';
            memWrite  <= '0';
            memToReg  <= '1';   --X?
            aluSrc    <= '0';
            regWrite  <= '0';
            aluOperation  <= "0001";
				mul_or_div    <="00";
                      
          when others => null; 
          
        end case category;
    end process muxControlLines;
    
end behavioral;
