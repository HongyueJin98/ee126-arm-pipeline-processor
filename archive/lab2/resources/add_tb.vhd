library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADD_tb is
end ADD_tb;

architecture tb of ADD_tb is
	signal in0,in1:STD_LOGIC_VECTOR(63 downto 0);
	signal output:STD_LOGIC_VECTOR(63 downto 0);
begin
	uut:entity work.ADD port map(in0=>in0,in1=>in1,output=>output);
	
	tb1:process
		constant period: time :=50ns;
		begin
			in0<= X"FFFFFFFF00000000";
			in1<= X"00000000FFFFFFFF";
			wait for period;
			assert (output=X"FFFFFFFFFFFFFFFF")
			report "test failed for input 1" severity error;

			in0<= X"0000000011111111";
			in1<= X"0000000111111111";
			wait for period;
			assert (output=X"0000000111111111")
			report "test failed for input 2" severity error;


			wait;
		end process;
end tb;