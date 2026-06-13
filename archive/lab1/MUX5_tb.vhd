library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX5_tb is
end MUX5_tb;

architecture tb of MUX5_tb is
	signal in0,in1:STD_LOGIC_VECTOR(4 downto 0);
	signal sel:std_logic;
	signal output:STD_LOGIC_VECTOR(4 downto 0);
begin
	uut:entity work.MUX5 port map(in0=>in0,in1=>in1,sel=>sel,output=>output);
	
	tb1:process
		constant period: time :=50ns;
		begin
			in0<= "00000";
			in1<= "00001";
			sel<= '0';
			wait for period;
			assert (output="00000")
			report "test failed for input 0" severity error;

			in0<= "00001";
			in1<= "00010";
			sel<= '0';
			wait for period;
			assert (output="00001")
			report "test failed for input 1" severity error;

			in0<= "00010";
			in1<= "00100";
			sel<= '0';
			wait for period;
			assert (output="00010")
			report "test failed for input 2" severity error;

			in0<= "00100";
			in1<= "01000";
			sel<= '0';
			wait for period;
			assert (output="00100")
			report "test failed for input 3" severity error;

			in0<= "01000";
			in1<= "10000";
			sel<= '0';
			wait for period;
			assert (output="01000")
			report "test failed for input 4" severity error;

			in0<= "00000";
			in1<= "00001";
			sel<= '1';
			wait for period;
			assert (output="00001")
			report "test failed for input 5" severity error;

			in0<= "00001";
			in1<= "00010";
			sel<= '1';
			wait for period;
			assert (output="00010")
			report "test failed for input 6" severity error;

			in0<= "00010";
			in1<= "00100";
			sel<= '1';
			wait for period;
			assert (output="00100")
			report "test failed for input 7" severity error;

			in0<= "00100";
			in1<= "01000";
			sel<= '1';
			wait for period;
			assert (output="01000")
			report "test failed for input 8" severity error;

			in0<= "01000";
			in1<= "10000";
			sel<= '1';
			wait for period;
			assert (output="10000")
			report "test failed for input 9" severity error;


			wait;
		end process;
end tb;