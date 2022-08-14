--Mux_4TO1 : select the output signal between 3 input signal (non standard mux)


library ieee;
use ieee.std_logic_1164.all;

entity MUX_4TO1 is
    generic(n: natural);
    port(
        signal0 : in std_logic_vector(n-1 downto 0);
        signal1 : in std_logic_vector(n-1 downto 0);
        signal2 : in std_logic_vector(n-1 downto 0);
        signal3 : in std_logic_vector(n-1 downto 0);

        controlSignal: in std_logic_vector(1 downto 0);
         selectedSignal: out std_logic_vector(n-1 downto 0)
    );
end entity;


architecture bhv of MUX_4TO1 is
begin
process(signal0,signal1,signal2,signal3,controlSignal) is
begin
if(controlSignal = "00") then
	selectedSignal <= signal0;
elsif(controlSignal = "01") then
	selectedSignal <= signal1;
elsif(controlSignal = "10") then
	selectedSignal <= signal2;
elsif(controlSignal = "11") then
	selectedSignal <= signal3;
end if;

end process;
end architecture bhv;



