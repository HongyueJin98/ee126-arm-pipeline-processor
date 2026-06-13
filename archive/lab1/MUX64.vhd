library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX64 is -- Two by one mux with 64 bit inputs/outputs
port(
	in0 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
	in1 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
	sel : in STD_LOGIC; -- selects in0 or in1
	output : out STD_LOGIC_VECTOR(63 downto 0)
);
end MUX64;

architecture MUX64_example of MUX64 is 

begin
	output <= in0 when (sel='0') else in1;

end MUX64_example;
