library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.13 in the textbook.
-- Check table on page2 of Green Card.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
--  To ensure proper functionality, you must implement the "don't-care" values in the funct field,
-- for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

architecture ALUControl_example of ALUControl is

signal temp : STD_LOGIC_VECTOR(3 downto 0);
begin
	process(ALUOp, Opcode)
	begin
		case ALUOp is
			when "00"=>
				temp <= "0010";
			when "01"=>
				temp <= "0111";
			when "10" =>
				if(Opcode="10001011000") then  --ADD
					temp <= "0010";
				elsif (Opcode= "11001011000") then --SUB
					temp <= "0110";
				elsif (Opcode="10001010000") then  --AND
					temp <= "0000";
				elsif (Opcode="10101010000") then --ORR
					temp <= "0001";
				elsif (Opcode(10 downto 1)="1001000100") then --ADDI
					temp <= "0010";
				elsif (Opcode(10 downto 1)="1001001000") then --ANDI
					temp <= "0000";
				elsif (Opcode(10 downto 1)="1101000100") then --SUBI
					temp <= "0110";
				elsif (Opcode(10 downto 1)="1011001000") then --ORRI
					temp <= "0001";
				else
					temp <= "XXXX";
				end if;
			when others =>
				temp <= "XXXX";
		end case;
	end process;
		Operation <= temp;
end ALUControl_example;