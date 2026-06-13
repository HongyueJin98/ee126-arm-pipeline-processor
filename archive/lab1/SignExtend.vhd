library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SignExtend is
port(
	x : in STD_LOGIC_VECTOR(31 downto 0);
	y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end SignExtend;

architecture SignExtend_example of SignExtend is

begin
	y(31 downto 0) <= x;
	y(63 downto 32) <=X"00000000" when(x(31)='0') else X"FFFFFFFF";

end SignExtend_example;