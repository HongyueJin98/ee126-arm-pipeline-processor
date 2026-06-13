library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dmem_tb is
end dmem_tb;

architecture tb of dmem_tb is
	signal WriteData : STD_LOGIC_VECTOR (63 downto 0);
	signal Address : STD_LOGIC_VECTOR (63 downto 0);
	signal MemRead : STD_LOGIC;
	signal MemWrite : STD_LOGIC;
	signal Clock : STD_LOGIC;
	signal ReadData : STD_LOGIC_VECTOR(63 downto 0);
	signal DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
begin
	UUT:entity work.DMEM port map(WriteData,Address,MemRead,MemWrite,Clock,ReadData,DEBUG_MEM_CONTENTS);

	clk_pro:process
		constant clk_period: time :=10 ns;
		begin
			Clock<='0';
			wait for clk_period;
			Clock<='1';
			wait for clk_period;
		end process;
	tb1:process
		constant period: time :=50 ns;
		begin
			WriteData <= X"0123456789ABCDEF";
			Address <= X"0000000000000000";
			MemRead <= '0';
			MemWrite <= '1';
			wait for period;

			WriteData <= X"FEDCBA9876543210";
			Address <= X"000000000000000F";
			MemRead <= '0';
			MemWrite <= '1';
			wait for period;

			WriteData <= X"0123456789ABCDEF";
			Address <= X"0000000000000000";
			MemRead <= '1';
			MemWrite <= '0';
			wait for period;
			assert (ReadData = X"0123456789ABCDEF")
			report "Error in Address 0" severity error;
			
			WriteData <= X"FEDCBA9876543210";
			Address <= X"00000000000000FF";
			MemRead <= '1';
			MemWrite <= '0';
			wait for period;
			assert (ReadData = X"FEDCBA9876543210")
			report "Error in Address FF" severity error;

		end process;
end tb;