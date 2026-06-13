library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ShiftLeft2 is
port(
	x: in STD_LOGIC_VECTOR(63 downto 0);
	y: out STD_LOGIC_VECTOR(63 downto 0)
);
end ShiftLeft2;

architecture ShiftLeft2_example of ShiftLeft2 is
begin
	y<= STD_LOGIC_VECTOR(unsigned(x) sll 2);

end ShiftLeft2_example;
