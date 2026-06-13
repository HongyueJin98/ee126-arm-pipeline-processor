library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registers_tb is
end registers_tb;

architecture tb of registers_tb is 
	
	signal RR1, RR2, WR:STD_LOGIC_VECTOR(4 downto 0);
	signal WD, RD1, RD2:STD_LOGIC_VECTOR(63 downto 0);
	signal RegWrite,Clock:STD_LOGIC;
	signal DEBUG_TMP_REGS,DEBUG_SAVED_REGS:STD_LOGIC_VECTOR(64*4 - 1 downto 0);
begin
	UUT:entity work.registers port map(RR1,RR2,WR,WD,RegWrite,Clock,RD1,RD2,DEBUG_TMP_REGS,DEBUG_SAVED_REGS);

	clk: process
		constant clk_period: time := 10 ns;
		begin
			Clock <= '0';
			wait for clk_period;
			Clock <= '1';
			wait for clk_period;
		end process;
	tb1: process
		constant period: time := 50 ns;
		begin
			RR1 <= "01001";
			RR2 <= "01010";
			WR  <= "10011";
			WD  <= X"0123456789ABCDEF";
			RegWrite <= '1';
			wait for period;
			assert (RD1 = X"0000000000000000" and RD2 = X"0000000000000001")
			report "Error in X9 OR X10" severity error;

			RR1 <= "01101";
			RR2 <= "01110";
			WR  <= "11111";
			WD  <= X"0123456789ABCDEF";
			RegWrite <= '1';
			wait for period;
			assert (RD1 = X"0000000000000008" and RD2 = X"0000000000000010")
			report "Error in X13 OR X14" severity error;

			RR1 <= "01111";
			RR2 <= "11111";
			WR  <= "11111";
			WD  <= X"0123456789ABCDEF";
			RegWrite <= '1';
			wait for period;
			assert (RD1 = X"0000000000000020" and RD2 = X"0000000000000000")
			report "Error in X15 OR X31" severity error;

			RR1 <= "01111";
			RR2 <= "10100";
			WR  <= "10100";
			WD  <= X"FFFFFFFFFFFFFFFF";
			RegWrite <= '1';
			wait for period;
			assert (RD1 = X"0000000000000020" and RD2 = X"FFFFFFFFFFFFFFFF")
			report "Error in X15 OR X20" severity error;
			wait for period;

		end process;
end tb;