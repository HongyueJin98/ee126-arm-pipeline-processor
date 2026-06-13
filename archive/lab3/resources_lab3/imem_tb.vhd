library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imem_tb is
end imem_tb;

architecture tb of imem_tb is
     signal Address : STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
     signal ReadData : STD_LOGIC_VECTOR(31 downto 0);
begin
	UUT:entity work.IMEM port map (Address, ReadData);

	tb1: process
		constant period: time :=50 ns;
		begin
			Address <= X"0000000000000000";
			wait for period;
			--assert (ReadData =X"00000000")
			--report "Error in Address 0" severity error;

			
			Address <= X"0000000000000004";
			wait for period;
			--assert (ReadData =X"FFFFFFFF")
			--report "Error in Address 1" severity error;
		end process;
end tb;