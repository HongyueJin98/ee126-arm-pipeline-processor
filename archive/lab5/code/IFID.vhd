library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;  

entity IfId is 
port(
          IfId_instr_in        : in std_logic_vector(31 downto 0);
          IfId_pc_in           : in std_logic_vector(63 downto 0);
          clk                  : in std_logic;
	  write_enable		: in std_logic;
          IfId_instr_out   : out std_logic_vector(31 downto 0);
          IfId_pc_out      : out std_logic_vector(63 downto 0));
end IfId;

architecture behavioral of IfId is

begin
process(clk)
        begin
	if( write_enable = '1') then
            if( clk'event and clk = '1') then
                IfId_instr_out <= IfId_instr_in;
                IfId_pc_out <= IfId_pc_in ;
            end if;
	end if;
        end process;
end behavioral;