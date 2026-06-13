library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- to_integer and unsigned


entity alu_tb is
end alu_tb;

architecture tb of alu_tb is
	signal in0, in1 : STD_LOGIC_VECTOR(63 downto 0);
	signal operation : STD_LOGIC_VECTOR(3 downto 0);
	signal result : STD_LOGIC_VECTOR(63 downto 0);
	signal zero : STD_LOGIC;
	signal overflow : STD_LOGIC;

begin
	UUT:entity work.ALU port map(in0 => in0, in1 => in1, operation=>operation, result=>result, zero=>zero, overflow=>overflow);
	
	tb1:process
		constant period: time :=50 ns;
		begin
			in0 <= X"000000000000000F";
			in1 <= X"0000000000000001";
			operation <= "0000";
			wait for period;
			assert (result = X"0000000000000001" and zero = '0' and overflow = '0')
			report "Error in and" severity error;
			wait for period;

			in0 <= X"FFFFFFFFFFFFFFFF";
			in1 <= X"0000000000000001";
			operation <= "0001";
			wait for period;
			assert (result = X"FFFFFFFFFFFFFFFF" and zero = '0' and overflow = '0')
			report "Error in or" severity error;
			wait for period;

			in0 <= X"7FFFFFFFFFFFFFFF";
			in1 <= X"0000000000000010";
			operation <= "0010";
			wait for period;
			assert (result = X"800000000000000F" and zero = '0' and overflow = '1')
			report "Error in overflow or add" severity error;
			wait for period;

			in0 <= X"000000000000000A";
			in1 <= X"0000000000000001";
			operation <= "0010";
			wait for period;
			assert (result = X"000000000000000B" and zero = '0' and overflow = '0')
			report "Error in add" severity error;
			wait for period;

			in0 <= X"000000000000000A";
			in1 <= X"0000000000000001";
			operation <= "0110";
			wait for period;
			assert (result = X"0000000000000009" and zero = '0' and overflow = '0')
			report "Error in subtract" severity error;
			wait for period;

			in0 <= X"000000000000000A";
			in1 <= X"000000000000000A";
			operation <= "0110";
			wait for period;
			assert (result = X"0000000000000000" and zero = '1' and overflow = '0')
			report "Error in subtract or zero" severity error;
			wait for period;
						
			in0 <= X"0000000000000000";
			in1 <= X"FFFFFFFFFFFFFFFF";
			operation <= "0111";
			wait for period;
			assert (result = X"FFFFFFFFFFFFFFFF" and zero = '0' and overflow = '0')
			report "Error in pass b" severity error;
			wait for period;

			in0 <= X"00FFFFFFFFFFFFFF";
			in1 <= X"0FFFFFFFFFFFFFFF";
			operation <= "0111";
			wait for period;
			assert (result = X"F000000000000000" and zero = '0' and overflow = '0')
			report "Error in NOR" severity error;
			wait for period;
		end process;
end tb;