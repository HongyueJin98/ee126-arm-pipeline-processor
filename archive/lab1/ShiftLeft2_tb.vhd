library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftLeft2_tb is
end ShiftLeft2_tb;

architecture tb of ShiftLeft2_tb is
	signal x:STD_LOGIC_VECTOR(63 downto 0);
	signal y:STD_LOGIC_VECTOR(63 downto 0);
begin
	uut:entity work.ShiftLeft2 port map(x=>x,y=>y);
	tb1:process
		constant period: time :=50ns;
		begin
			x<=X"000000000000000F";
			wait for period;
			assert (y=X"000000000000003A")
			report "test failed for input 1" severity error;

			x<=X"0000000000000B00";
			wait for period;
			assert (y=X"0000000000002C00")
			report "test failed for input 2" severity error;

			x<=X"F000000000000001";
			wait for period;
			assert (y=X"C000000000000004")
			report "test failed for input 3" severity error;
			wait;
		end process;
end tb;
