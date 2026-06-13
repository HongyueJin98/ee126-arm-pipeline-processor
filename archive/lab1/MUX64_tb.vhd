library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX64_tb is
end MUX64_tb;

architecture tb of MUX64_tb is
	signal in0,in1:STD_LOGIC_VECTOR(63 downto 0);
	signal sel:std_logic;
	signal output:STD_LOGIC_VECTOR(63 downto 0);
begin
	uut:entity work.MUX64 port map(in0=>in0,in1=>in1,sel=>sel,output=>output);
	
	tb1:process
		constant period: time :=50ns;
		begin
			in0<= X"FFFFFFFF00000000";
			in1<= X"00000000FFFFFFFF";
			sel<= '0';
			wait for period;
			assert (output=X"FFFFFFFF00000000")
			report "test failed for input 1" severity error;

			in0<= X"FFFFFFFFFFFFFFFF";
			in1<= X"0000000000000000";
			sel<= '1';
			wait for period;
			assert (output=X"0000000000000000")
			report "test failed for input 2" severity error;


			wait;
		end process;
end tb;