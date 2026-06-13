library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SignExtend_tb is
end SignExtend_tb;

architecture tb of SignExtend_tb is
	signal x:STD_LOGIC_VECTOR(31 downto 0);
	signal y:STD_LOGIC_VECTOR(63 downto 0);
begin
	UUT: entity work.SignExtend port map(x=>x, y=>y);
	tb1: process
		constant period: time :=50ns;
		begin
			x<=X"00000001";
			wait for period;
			assert (y=X"0000000000000001")
			report "test failed for input 1" severity error;

			x<=X"F0000001";
			wait for period;
			assert (y=X"FFFFFFFFF0000001")
			report "test failed for input 2" severity error;

			x<=X"10000001";
			wait for period;
			assert (y=X"0000000010000001")
			report "test failed for input 3" severity error;

			wait;
		end process;
end tb;
	