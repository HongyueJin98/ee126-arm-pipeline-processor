library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_tb is
end PC_tb;

architecture tb of PC_tb is
	signal clk, write_enable, rst:STD_LOGIC;
	signal AddressIn:STD_LOGIC_VECTOR(63 downto 0);
	signal AddressOut:STD_LOGIC_VECTOR(63 downto 0);
begin
	UUT: entity work.PC port map(clk=>clk, write_enable=>write_enable,rst=>rst,AddressIn=>AddressIn,AddressOut=>AddressOut);
	
	clk_pro:process
		constant clk_period: time :=5ns;
		begin
			clk<='0';
			wait for clk_period;
			clk<='1';
			wait for clk_period;
		end process;
	tb1:process
		constant period: time :=10ns;
		begin
			write_enable <= '1';
			AddressIn <=X"FFFFFFFFFFFFFFFF";
			rst<='0';
			wait for period;
			
			write_enable <= '0';
			AddressIn <=X"ABCDEF12ABCDEF12";
			rst<='0';
			wait for period;

			write_enable <= '0';
			AddressIn <=X"1234567812345678";
			rst<='1';
			wait for period;

			write_enable <= '1';
			AddressIn <=X"89ABCDEF89ABCDEF";
			rst<='1';
			wait for period;
		end process;
end tb;